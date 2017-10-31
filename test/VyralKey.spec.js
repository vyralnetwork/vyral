var abi = require('ethereumjs-abi')

var a = abi.methodID('join', ['address']).toString('hex') + abi.rawEncode(['address'], ["0x94dc1cf66c8fd62ef3bd7da53f47423862839823"]).toString('hex');
console.log(a)

var b = abi.methodID('purchaseTokens', []).toString('hex');// + abi.rawEncode([], []).toString('hex');
console.log(b)
28ffe6c8000000000000000000000000
94dc1cf66c8fd62ef3bd7da53f47423862839823