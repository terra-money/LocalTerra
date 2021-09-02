import { LCDClient, MsgMigrateCode, MsgInstantiateContract, MnemonicKey, isTxError } from '@terra-money/terra.js';
import * as fs from 'fs';

// set default wasm binary
if (!process.env.FILENAME_WASM) {
	process.env['FILENAME_WASM'] = 'send_to_burn_address.wasm';
}

// set default code_id
if (!process.env.CODE_ID) {
	process.env['CODE_ID'] = '1';
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

// migrate code

const migrateCode = new MsgMigrateCode(
  wallet.key.accAddress,
  parseInt(process.env.CODE_ID),
  fs.readFileSync(`../../contracts/columbus-5/${process.env.FILENAME_WASM}`).toString('base64')
);

const migrateCodeTx = await wallet.createAndSignTx({
  msgs: [migrateCode],
  fees: { uluna: 600000000, ukrw:600000000},
  gasPrices: { uluna:100 },
  memo: "test to migrate code for older localterra",
});

const migrateCodeTxResult = await terra.tx.broadcast(migrateCodeTx);

console.log(migrateCodeTxResult);

//
console.log("code migrated.");
//
