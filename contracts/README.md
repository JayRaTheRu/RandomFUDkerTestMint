# FUDkers NFT Contract Deployment and Configuration Guide

## Deployment with Remix
1. Open Remix IDE and import the FUDkers contract.
2. Compile the contract using the Solidity compiler.
3. Deploy the contract using the Injected Web3 environment connected to your Ethereum wallet.

## Owner Interface Configuration
Post-deployment, the contract owner can configure the contract using the following functions:

### `setBaseURI(string memory _newBaseURI)`
- Sets the base URI for token metadata.
- Example usage: Call this function with `"https://example.com/nft/"` to set the base URI to `https://example.com/nft/`.

### `setMintPrice(uint256 _newMintPrice)`
- Sets the price for minting an NFT in Wei.
- Example usage: Call this function with `"10000000000000000"` to set the mint price to 0.01 ETH.

### `setSaleTime(uint256 _saleStartTime, uint256 _saleEndTime)`
- Sets the start and end times for the NFT sale in UNIX timestamp format.
- Example usage: Call this function with start and end timestamps to define the sale period.

### `mint()`
- Public function that allows users to mint an NFT during the sale period by sending the correct mint price.
- The minted NFT will be a random card type, considering the maximum supply for each type.

### `withdraw()`
- Allows the contract owner to withdraw all Ether stored in the contract to their own wallet.

## Front-End Interaction
For front-end interaction, use web3.js or ethers.js to connect to the contract and call the owner functions. Ensure transactions are initiated from the owner's account.

## Additional Information
- Test the contract thoroughly on a testnet before deploying to the mainnet.
- Adjust the mint price, sale time, and base URI according to your project's requirements.
- Monitor the contract's balance and withdraw funds periodically for security.

Remember to replace placeholders and example values with actual data relevant to your project.
