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

async function main() {
  const mainnetClient = new LCDClient({
    URL: MAINNET_LCD_URL,
    chainID: MAINNET_CHAIN_ID,
  });

  const testnetClient = new LCDClient({
    URL: TESTNET_LCD_URL,
    chainID: TESTNET_CHAIN_ID,
  });

  const mk = new MnemonicKey({
    mnemonic: MNEMONIC,
  });

  const wallet = testnetClient.wallet(mk);

  let lastSuccessVotePeriod: number;
  let lastVotePeriodVoteMsgs: MsgExchangeRateVote[] = [];

  while (true) {
    const [rates, oracleParams, latestBlock] = await Promise.all([
      mainnetClient.oracle.exchangeRates(),
      testnetClient.oracle.parameters(),
      testnetClient.tendermint.block(),
    ]).catch(err => []);

    if (!rates) {
      await new Promise((resolve) => setTimeout(resolve, 5000));
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
      await new Promise((resolve) => setTimeout(resolve, 1000));
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

    await new Promise((resolve) => setTimeout(resolve, 5000));
  }
}

main().catch(console.error);
