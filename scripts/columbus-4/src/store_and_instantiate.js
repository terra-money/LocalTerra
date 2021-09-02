import { LCDClient, MsgStoreCode, MsgInstantiateContract, MnemonicKey, isTxError } from '@terra-money/terra.js';
import * as fs from 'fs';

// set default wasm binary
if (!process.env.FILENAME_WASM) {
        process.env['FILENAME_WASM']='send_to_burn_address.wasm';
}

// set default init msg for coontract
if (!process.env.FILENAME_INITMSG) {
        process.env['FILENAME_INITMSG']=process.env.FILENAME_WASM+'.init.json';
}

// test1 key from localterra accounts
const mk = new MnemonicKey({
  mnemonic: 'notice oak worry limit wrap speak medal online prefer cluster roof addict wrist behave treat actual wasp year salad speed social layer crew genius'
})

// connect to localterra
const terra = new LCDClient({
  URL: 'http://localhost:1317',
  chainID: 'localterra',
});

const wallet = terra.wallet(mk);

// store code

const storeCode = new MsgStoreCode(
  wallet.key.accAddress,
  fs.readFileSync(`../../contracts/columbus-4/${process.env.FILENAME_WASM}`).toString('base64')
);

const storeCodeTx = await wallet.createAndSignTx({
  msgs: [storeCode],
  gasPrices: { uluna:100 }, 
});

const storeCodeTxResult = await terra.tx.broadcast(storeCodeTx);

console.log(storeCodeTxResult);

//
console.log("code stored.");
//

// instantiate contract

if (isTxError(storeCodeTxResult)) {
  throw new Error(
    `store code failed. code: ${storeCodeTxResult.code}, codespace: ${storeCodeTxResult.codespace}, raw_log: ${storeCodeTxResult.raw_log}`
  );
}

const {
  store_code: { code_id },
} = storeCodeTxResult.logs[0].eventsByType;

const initMsg = JSON.parse(fs.readFileSync(`../../contracts/columbus-4/${process.env.FILENAME_INITMSG}`));

let instantiate = new MsgInstantiateContract(
  wallet.key.accAddress,
  +code_id[0], // code ID
  initMsg,
  { uluna: 20000000, ukrw: 2000000 }, // init coins
  true, // set migratable
);

const instantiateTx = await wallet.createAndSignTx({
  msgs: [instantiate],
  gasPrices: { uluna:100 },
});
const instantiateTxResult = await terra.tx.broadcast(instantiateTx);

console.log(instantiateTxResult);

if (isTxError(instantiateTxResult)) {
  throw new Error(
    `instantiate failed. code: ${instantiateTxResult.code}, codespace: ${instantiateTxResult.codespace}, raw_log: ${instantiateTxResult.raw_log}`
  );
}

const {
  instantiate_contract: { contract_address },
} = instantiateTxResult.logs[0].eventsByType;

fs.writeFileSync(`../../log/deployed.${instantiateTxResult.height}.json`, JSON.stringify(instantiateTxResult,'','\t'));

console.log("contract instantiated.");
