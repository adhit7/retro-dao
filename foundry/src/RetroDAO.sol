// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract RetroDAO is Ownable {
    struct Proposal {
      uint256 nftTokenId;
      uint256 deadline;
      uint256 yayVotes;
      uint256 nayVotes;
      bool executed;
      mapping(uint256 => bool) voters;
    }

    // Create a mapping of ID to Proposal
    mapping(uint256 => Proposal) public proposals;

    // Number of proposals that have been created
    uint256 public numProposals;

    INFTMarketplace nftMarketplace;
    IRetroNFT retroNFT;

    constructor(address _nftMarketplace, address _retroNFT) Ownable(msg.sender) payable {
      nftMarketplace = INFTMarketplace(_nftMarketplace);
      retroNFT = IRetroNFT(_retroNFT);
    }

    // Create a modifier which only allows a function to be
    // called by someone who owns at least 1 RetroNFT
        modifier nftHolderOnly() {
            require(retroNFT.balanceOf(msg.sender) > 0, "NOT_A_DAO_MEMBER");
            _;
        }


   
    function createProposal(uint256 _nftTokenId)
        external
        nftHolderOnly
        returns (uint256)
    {
        require(nftMarketplace.available(_nftTokenId), "NFT_NOT_FOR_SALE");
        Proposal storage proposal = proposals[numProposals];
        proposal.nftTokenId = _nftTokenId;
        // Set the proposal's voting deadline to be (current time + 5 minutes)
        proposal.deadline = block.timestamp + 5 minutes;

        numProposals++;

        return numProposals - 1;
    }

    // Create a modifier which only allows a function to be
    // called if the given proposal's deadline has not been exceeded yet
        modifier activeProposalOnly(uint256 proposalIndex) {
            require(
                proposals[proposalIndex].deadline > block.timestamp,
                "DEADLINE_EXCEEDED"
            );
            _;
        }




        // Create an enum named Vote containing possible options for a vote
      enum Vote {
          YAY, // YAY = 0
          NAY // NAY = 1
      }


    
      function voteOnProposal(uint256 proposalIndex, Vote vote)
          external
          nftHolderOnly
          activeProposalOnly(proposalIndex)
      {
          //Get the proposal
          Proposal storage proposal = proposals[proposalIndex];

          uint256 voterNFTBalance = retroNFT.balanceOf(msg.sender);
          uint256 numVotes = 0;

          // Calculate how many NFTs are owned by the voter
          // that haven't already been used for voting on this proposal
          for (uint256 i = 0; i < voterNFTBalance; i++) {
              uint256 tokenId = retroNFT.tokenOfOwnerByIndex(msg.sender, i);
              if (proposal.voters[tokenId] == false) {
                  numVotes++;
                  proposal.voters[tokenId] = true;
              }
          }
          require(numVotes > 0, "ALREADY_VOTED");

          if (vote == Vote.YAY) {
              proposal.yayVotes += numVotes;
          } else {
              proposal.nayVotes += numVotes;
          }
      }


      // Create a modifier which only allows a function to be
    // called if the given proposals' deadline HAS been exceeded
    // and if the proposal has not yet been executed
    modifier inactiveProposalOnly(uint256 proposalIndex) {
        require(
            proposals[proposalIndex].deadline <= block.timestamp,
            "DEADLINE_NOT_EXCEEDED"
        );
        require(
            proposals[proposalIndex].executed == false,
            "PROPOSAL_ALREADY_EXECUTED"
        );
        _;
      }


     
      function executeProposal(uint256 proposalIndex)
          external
          nftHolderOnly
          inactiveProposalOnly(proposalIndex)
      {
          Proposal storage proposal = proposals[proposalIndex];

          // If the proposal has more YAY votes than NAY votes
          // purchase the NFT from the FakeNFTMarketplace
          if (proposal.yayVotes > proposal.nayVotes) {
              uint256 nftPrice = nftMarketplace.getPrice();
              require(address(this).balance >= nftPrice, "NOT_ENOUGH_FUNDS");
              nftMarketplace.purchase{value: nftPrice}(proposal.nftTokenId);
          }
          proposal.executed = true;
      }

      function withdrawEther() external onlyOwner {
          uint256 amount = address(this).balance;
          require(amount > 0, "Nothing to withdraw, contract balance empty");
          (bool sent, ) = payable(owner()).call{value: amount}("");
          require(sent, "FAILED_TO_WITHDRAW_ETHER");
      }

      // The following two functions allow the contract to accept ETH deposits
      // directly from a wallet without calling a function
      receive() external payable {}

      fallback() external payable {}
}

/**
 * Interface for the FakeNFTMarketplace
 */
interface INFTMarketplace {
   
    function getPrice() external view returns (uint256);

    
    function available(uint256 _tokenId) external view returns (bool);

  
    function purchase(uint256 _tokenId) external payable;
}

interface IRetroNFT {
  
    function balanceOf(address owner) external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256);
}