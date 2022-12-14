// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.7.3/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.7.3/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.7.3/security/Pausable.sol";
import "@openzeppelin/contracts@4.7.3/access/Ownable.sol";
import "@openzeppelin/contracts@4.7.3/utils/Counters.sol";

contract Berries is ERC721, ERC721Enumerable, Pausable, Ownable {
    using Counters for Counters.Counter;

       uint256 maxSupply = 30; 
       bool public publicMintOpen = false;
       bool public allowListMintOpen = false;

       mapping(address => bool) public allowList;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Berries", "BRS") {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmVEnjMeGXYKK1YR8XtDZjSdR8eDQmsmNghptyLW1cAp5B/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
//Will allow you to modify mint windows (when each category will mint and close for the other)
    function editMintWindows(
        bool _publicMintOpen,
        bool _allowListMintOpen
    )
     external onlyOwner{
    publicMintOpen = _publicMintOpen;
    allowListMintOpen = _allowListMintOpen;

    }

     //Add publicMint and allowListMintOpen variables 
    //require only allowList people to mint 
     function allowListMint() public payable {
       require(allowListMintOpen, "allowList Mint closed");
       require(allowList[msg.sender], "You don't qualify to mint");
        require(msg.value == 0.001 ether, "Not enough funds");
       internalMint();
    }

      //add payment
      //limiting of the supply
    function publicMint() public payable {
       require(publicMintOpen, "public Mint closed");
        require(msg.value == 0.01 ether, "Not enough funds");
       internalMint();
    }

      //simplifying code
    function internalMint() internal {
 require(totalSupply() < maxSupply, "Sold out!");
       uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
          
    }

    function withdraw(address _addr) external onlyOwner {
        // get balance of the contract
        uint256 balance = address(this).balance; //(this) means this current balance.
        payable(_addr).transfer(balance);
    }

    //funtion for the mapping tracking allowList addresses
    //populate the allowList

    function setAllowList(address[] calldata addresses) external onlyOwner {
          for(uint256 i = 0; i < addresses.length; i++){
              allowList[addresses[i]] = true;
          }
    }
   

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
