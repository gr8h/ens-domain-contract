
const main = async () => {
    const domainContractFactory = await hre.ethers.getContractFactory('Domains');
    const domainContract = await domainContractFactory.deploy("Sonic");
    await domainContract.deployed();
  
    console.log("Contract deployed to:", domainContract.address);
  
    // CHANGE THIS DOMAIN TO SOMETHING ELSE! I don't want to see OpenSea full of Sonics lol
    let txn = await domainContract.register("Tails",  {value: hre.ethers.utils.parseEther('0.1')});
    await txn.wait();
    console.log("Minted domain Tails.Sonic");
  
    txn = await domainContract.setRecord("Tails", "Am I Sonic or a ninja??");
    await txn.wait();
    console.log("Set record for Tails.Sonic");
  
    const address = await domainContract.getAddress("Tails");
    console.log("Owner of domain Tails:", address);
  
    const balance = await hre.ethers.provider.getBalance(domainContract.address);
    console.log("Contract balance:", hre.ethers.utils.formatEther(balance));
  }
  
  const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };
  
  runMain();