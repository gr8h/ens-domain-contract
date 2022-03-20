
const main = async () => {

    const domainContractFactory = await hre.ethers.getContractFactory('Domains');
    const domainContract = await domainContractFactory.deploy('Sonic');
    await domainContract.deployed();

    const [owner, randomPerson] = await hre.ethers.getSigners();
    console.log("Contract deployed to:", domainContract.address);
    console.log("Contract deployed by:", owner.address);

    // the second variable - value. This is the money
    let txn = await domainContract.register("Tails",  {value: hre.ethers.utils.parseEther('0.1')});
    await txn.wait();

    const domainOwner = await domainContract.getAddress("Tails");
    console.log("Owner of domain Tails:", domainOwner);
    
    // Trying to set a record that doesn't belong to me!
    // txn = await domainContract.connect(randomPerson).setRecord("doom", "Haha my domain now!");

    const balance = await hre.ethers.provider.getBalance(domainContract.address);
    console.log("Contract balance:", hre.ethers.utils.formatEther(balance));

    // Quick! Grab the funds from the contract! (as superCoder)
    try {
      txn = await domainContract.connect(randomPerson).withdraw();
      await txn.wait();
    } catch(error){
      console.log("Could not rob contract");
    }

    // Let's look in their wallet so we can compare later
    let ownerBalance = await hre.ethers.provider.getBalance(owner.address);
    console.log("Balance of owner before withdrawal:", hre.ethers.utils.formatEther(ownerBalance));

    txn = await domainContract.connect(owner).withdraw();
    await txn.wait();

    const contractBalance = await hre.ethers.provider.getBalance(domainContract.address);
    ownerBalance = await hre.ethers.provider.getBalance(owner.address);

    console.log("Contract balance after withdrawal:", hre.ethers.utils.formatEther(contractBalance));
    console.log("Balance of owner after withdrawal:", hre.ethers.utils.formatEther(ownerBalance));
  };
  
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