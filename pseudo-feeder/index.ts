import {
  LCDClient,
  MnemonicKey,
  MsgExchangeRateVote,
} from "@terra-money/terra.js";

const {
  MAINNET_LCD_URL = "https://lcd.terra.dev",
  MAINNET_CHAIN_ID = "columbus-3",
  TESTNET_LCD_URL = "http://localhost:1317",
  TESTNET_CHAIN_ID = "localterra",
  MNEMONIC = "satisfy adjust timber high purchase tuition stool faith fine install that you unaware feed domain license impose boss human eager hat rent enjoy dawn",
} = process.env;

function delay(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function waitForFirstBlock(client: LCDClient) {
  let shouldTerminate = false

  console.info('waiting for first block');

  while (!shouldTerminate) {
    shouldTerminate = await client.tendermint
      .blockInfo()
      .then(async (blockInfo) => {
        await delay(5000);
      
        if (blockInfo?.block) {
          return +blockInfo.block?.header.height > 0;
        }
        
        return false;
      })
      .catch(async (err) => {
        console.error(err);
        await delay(1000);
        return false;
      });

    if (shouldTerminate) {
      break;
    }
  }
}

async function main() {
  const mainnetClient = new LCDClient({
    URL: MAINNET_LCD_URL,
    chainID: MAINNET_CHAIN_ID,
  });

  const testnetClient = new LCDClient({
    URL: TESTNET_LCD_URL,
    chainID: TESTNET_CHAIN_ID,
    gasPrices: "0.15uluna",
    gasAdjustment: 1.4
  });

  const mk = new MnemonicKey({
    mnemonic: MNEMONIC,
  });

  const wallet = testnetClient.wallet(mk);

  let lastSuccessVotePeriod: number;
  let lastVotePeriodVoteMsgs: MsgExchangeRateVote[] = [];

  await waitForFirstBlock(testnetClient);

  while (true) {
    const [rates, oracleParams, latestBlock] = await Promise.all([
      mainnetClient.oracle.exchangeRates(),
      testnetClient.oracle.parameters(),
      testnetClient.tendermint.blockInfo(),
    ]).catch((err) => []);

    if (!rates) {
      await delay(5000);
      continue;
    }

    const oracleVotePeriod = oracleParams.vote_period;
    const currentBlockHeight = parseInt(latestBlock.block.header.height, 10);
    const currentVotePeriod = Math.floor(currentBlockHeight / oracleVotePeriod);
    const indexInVotePeriod = currentBlockHeight % oracleVotePeriod;

    if (
      (lastSuccessVotePeriod && lastSuccessVotePeriod === currentVotePeriod) ||
      indexInVotePeriod >= oracleVotePeriod - 1
    ) {
      await delay(1000);
      continue;
    }

    const voteMsgs: MsgExchangeRateVote[] = rates
      .toArray()
      .map(
        (r) =>
          new MsgExchangeRateVote(
            r.amount,
            r.denom,
            "salt",
            mk.accAddress,
            mk.valAddress
          )
      );

    const prevoteMsgs = voteMsgs.map((vm) => vm.getPrevote());
    const msgs = [...lastVotePeriodVoteMsgs, ...prevoteMsgs];
    const tx = await wallet.createAndSignTx({ msgs });

    await testnetClient.tx
      .broadcast(tx)
      .then((result) => {
        console.log(
          `vote_period: ${currentVotePeriod}, txhash: ${result.txhash}`
        );

        lastSuccessVotePeriod = currentVotePeriod;
        lastVotePeriodVoteMsgs = voteMsgs;
      })
      .catch((err) => {
        console.error(err.message);
      });

    await delay(5000);
  }
}

main().catch(console.error);
