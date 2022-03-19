
const main = async () => {

    const domainContractFactory = await hre.ethers.getContractFactory('Domains');
    const domainContract = await domainContractFactory.deploy('banana');
    await domainContract.deployed();

    const [owner, randomPerson] = await hre.ethers.getSigners();
    console.log("Contract deployed to:", domainContract.address);
    console.log("Contract deployed by:", owner.address);

    // the second variable - value. This is the money
    const txn = await domainContract.register("yellow",  {value: hre.ethers.utils.parseEther('0.1')});
    await txn.wait();

    const domainOwner = await domainContract.getAddress("yellow");
    console.log("Owner of domain:", domainOwner);

    // Trying to set a record that doesn't belong to me!
    // txn = await domainContract.connect(randomPerson).setRecord("doom", "Haha my domain now!");

    const balance = await hre.ethers.provider.getBalance(domainContract.address);
    console.log("Contract balance:", hre.ethers.utils.formatEther(balance));

    await txn.wait();
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