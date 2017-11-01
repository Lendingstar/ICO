const LSMultiSale = artifacts.require("./LSMultiSale.sol");

const tokenPriceEther = 1e-18;
const minInvestment = new web3.BigNumber(100000000000000000); // 0.1 Eth
const goalInTokens = new web3.BigNumber(10); // 10 Tokens
const contractDuration = 86400; // 1 day
//const contractDuration = 68400; // 19 hours
//const contractDuration = 7200; // 2 hours
const wallet = "0xe2b8D58589bE48fF861464695995D98f55ebf1d5";


module.exports = function(deployer)
{
    var json = require("../build/contracts/LSToken.json");
    var LSToken = web3.eth.contract(json.abi);
    var tokenContract = LSToken.at(json.networks[4].address);

    console.log("Token Particle Price (Eth): " + tokenPriceEther);

    const tokenParticlePriceWei = new web3.BigNumber(tokenPriceEther).mul(Math.pow(10, 18));
    console.log("Token Particle Price (Wei): " + tokenParticlePriceWei.toNumber());

    const minTokenParticle = new web3.BigNumber(1);
    const rate = minTokenParticle.div(tokenParticlePriceWei);
    console.log("Rate: " + rate.toNumber());

    console.log("Min Investment: " + minInvestment.toNumber());

    console.log("Goal in Tokens: " + goalInTokens.toNumber());

    var goalInTokenParticle = goalInTokens.mul(Math.pow(10, tokenContract.decimals()));
    console.log("Goal in Token Particles: " + goalInTokenParticle.toNumber());

 
    const goalInWei = tokenParticlePriceWei.mul(goalInTokenParticle);
    console.log("Goal in Wei: " + goalInWei.toNumber());
    console.log("Goal in Eth: " + web3.fromWei(goalInWei.toNumber()));


    const startTime = web3.eth.getBlock(web3.eth.blockNumber).timestamp + 180; // 180 seconds in the future
    var d = new Date(0);
    d.setUTCSeconds(startTime);
    console.log("Start: " + startTime + " (" + d + ")");

    const endTime = startTime + contractDuration;
    d = new Date(0);
    d.setUTCSeconds(endTime);
    console.log("End: " + endTime + " (" + d + ")");

    console.log("Wallet: " + wallet);
    console.log("Token: " + tokenContract.address);

    deployer.deploy(LSMultiSale, rate, goalInWei, minInvestment, startTime, endTime, tokenContract.address, wallet);
};
