import * as net from "net";
import { randomBytes } from "crypto";
import {
  LCDClient,
  MnemonicKey,
  MsgAggregateExchangeRateVote,
} from "@terra-money/terra.js";
import { parse } from "toml";
import * as fs from "fs";
import * as ms from "ms"

const {
  MAINNET_LCD_URL = "https://lcd.terra.dev",
  MAINNET_CHAIN_ID = "columbus-5",
  TESTNET_LCD_URL = "http://localhost:1317",
  TESTNET_CHAIN_ID = "localterra",
  MNEMONIC = "satisfy adjust timber high purchase tuition stool faith fine install that you unaware feed domain license impose boss human eager hat rent enjoy dawn",
} = process.env;

const config = parse(fs.readFileSync("./config.toml").toString());

/* unused
const timeout_propose = toMs(config.consensus.timeout_propose); // 3s by default
const timeout_propose_delta = toMs(config.consensus.timeout_propose_delta);  // 500ms by default
const timeout_prevote = toMs(config.consensus.timeout_prevote); // 1s by default
const timeout_prevote_delta = toMs(config.consensus.timeout_prevote_delta); // 500ms by default
const timeout_prevcommit = toMs(config.consensus.timeout_precommit); // 1s by default
const timeout_precommit_delta = toMs(config.consensus.timeout_precommit_delta); // 500ms by default
*/
const timeoutCommit = ms(config.consensus.timeout_commit); // 5s by default

function delay(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function checkConnection(host: string, port: number, timeout = 10000) {
  return new Promise(function (resolve, reject) {
    timeout = timeout || 10000; // default of 10 seconds
    var timer = setTimeout(function () {
      reject("timeout");
      socket.end();
    }, timeout);
    var socket = net.createConnection(port, host, function () {
      clearTimeout(timer);
      resolve("");
      socket.end();
    });
    socket.on("error", function (err) {
      clearTimeout(timer);
      reject(err);
    });
  });
}

async function waitForFirstBlock(client: LCDClient) {
  let shouldTerminate = false;

  console.info("waiting for connectivity");

  const [_, host, port] = /https?:\/\/([a-zA-Z0-9][a-zA-Z0-9\.-]+)\:(\d+)/.exec(
    TESTNET_LCD_URL
  );

  while (await checkConnection(host, +port).catch(err => err));

  console.info("waiting for first block");

  while (!shouldTerminate) {
    await delay(timeoutCommit);
    shouldTerminate = await client.tendermint
      .blockInfo()
      .then(async (blockInfo) => {

        if (blockInfo?.block) {
          return +blockInfo.block?.header.height > 0;
        }

        return false;
      })
      .catch(async (err) => {
        console.error(err);
        await delay(timeoutCommit);
        return false;
      });

    if (shouldTerminate) {
      break;
    }
  }
}

const mainnetClient = new LCDClient({
  URL: MAINNET_LCD_URL,
  chainID: MAINNET_CHAIN_ID,
});

const testnetClient = new LCDClient({
  URL: TESTNET_LCD_URL,
  chainID: TESTNET_CHAIN_ID,
  gasPrices: "0.01133uluna",
  gasAdjustment: 1.4,
});

const mk = new MnemonicKey({
  mnemonic: MNEMONIC,
});

const wallet = testnetClient.wallet(mk);

async function loop() {
  let lastSuccessVotePeriod: number;
  let lastSuccessVoteMsg: MsgAggregateExchangeRateVote;

  // to get initial rates and params
  let [rates, oracleParams] = await Promise.all([
    mainnetClient.oracle.exchangeRates(),
    testnetClient.oracle.parameters(),
  ]);

  setInterval(async () => {
    try {
      [rates, oracleParams] = await Promise.all([
        mainnetClient.oracle.exchangeRates(),
        testnetClient.oracle.parameters(),
      ]);
    } catch (e) { }
  }, 10000);  // 5s -> 10s: to avoid rate limit

  while (true) {
    const latestBlock = await testnetClient.tendermint.blockInfo();

    const oracleVotePeriod = oracleParams.vote_period;
    const currentBlockHeight = parseInt(latestBlock.block.header.height, 10);
    const currentVotePeriod = Math.floor(currentBlockHeight / oracleVotePeriod);
    const indexInVotePeriod = currentBlockHeight % oracleVotePeriod;
    if (
      (lastSuccessVotePeriod && (lastSuccessVotePeriod === currentVotePeriod)) ||
      (indexInVotePeriod >= oracleVotePeriod - 1)
    ) {
      await delay(timeoutCommit);
      continue;
    }

    const coins = rates
      .filter(
        (coin) =>
          oracleParams.whitelist.findIndex((o) => o.name === coin.denom) !== -1
      )
      .toArray()
      .map((r) => `${r.amount}${r.denom}`)
      .join(",");

    const voteMsg = new MsgAggregateExchangeRateVote(
      coins,
      randomBytes(2).toString("hex"),
      mk.accAddress,
      mk.valAddress
    );

    const msgs = [lastSuccessVoteMsg, voteMsg.getPrevote()].filter(Boolean);
    try {
      const tx = await wallet.createAndSignTx({ msgs });
      const result = await testnetClient.tx.broadcast(tx);
      console.log(`vote_period: ${currentVotePeriod}, txhash: ${result.txhash}`);
      lastSuccessVotePeriod = currentVotePeriod;
      lastSuccessVoteMsg = voteMsg;
    }
    catch (err) {
      console.log(err.message);
      delay(timeoutCommit);
    };
    await delay(timeoutCommit * (oracleVotePeriod - 1));   // (period-1) because of broadcast
  }
}

(async () => {
  await waitForFirstBlock(testnetClient);

  while (true) {
    await loop().catch(console.error);
    await delay(timeoutCommit * 5);
  }
})();
