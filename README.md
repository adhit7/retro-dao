# RetroDAO

RetroDAO is a decentralized autonomous organization (DAO) contract designed to manage and vote on NFT-related proposals. Members of the DAO can create proposals to purchase NFTs, vote on them, and decide whether to buy or not, using their NFTs as voting power.

## Features

- **Proposal Creation**: Only members with at least one NFT can create proposals.
- **Voting**: DAO members can vote on proposals using their NFTs, with the ability to cast a `YAY` or `NAY` vote.
- **NFT Marketplace Integration**: Proposals are linked to an NFT marketplace to verify the availability of NFTs before creating a proposal.
- **Withdraw Ether**: The DAO owner can withdraw Ether from the contract balance.

## Smart Contracts

1. **RetroDAO Contract**: The main contract that allows DAO members to create proposals and vote on them. It uses two external contracts:
   - **NFT Marketplace Contract**: Verifies the availability of NFTs.
   - **RetroNFT Contract**: Checks NFT ownership and voting eligibility.

2. **Voting Mechanism**: The contract uses the following logic:
   - `YAY` votes are counted as positive votes for a proposal.
   - `NAY` votes are counted as negative votes for a proposal.
   - Each NFT holder can vote once for each proposal, with their NFT serving as the voting mechanism.

3. **Withdraw Ether**: The contract owner can withdraw any Ether in the contract balance.
