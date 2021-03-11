var bitcoinValue = document.querySelector(".bitcoin-value");
var satoshiValue = document.querySelector(".satoshi-value");
var usdValue = document.querySelector(".usd-value");
var currentDollar = document.querySelector(".current-usd");
var dollarInteger = parseInt(currentDollar.innerHTML);


function handleSatoshi() {
    
    satoshiValue.value = bitcoinValue.value * 10000000;
    usdValue.value = (bitcoinValue.value * dollarInteger).toFixed(2);

}


bitcoinValue.addEventListener('keyup',handleSatoshi)

function handleBitcoin() {
    

    bitcoinValue.value = satoshiValue.value / 10000000;
    var usd = satoshiValue.value / 10000000 * dollarInteger;
    usdValue.value = usd.toFixed(2);

}


satoshiValue.addEventListener('keyup',handleBitcoin)

function handleBitcoinAndSatoshi() {
    

    bitcoinValue.value = usdValue.value / dollarInteger;
    satoshiValue.value = usdValue.value / dollarInteger * 10000000;

}


usdValue.addEventListener('keyup',handleBitcoinAndSatoshi)