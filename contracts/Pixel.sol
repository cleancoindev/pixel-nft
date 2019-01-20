pragma solidity ^0.4.24;
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./TradeableERC721Token.sol";

/**
 * @title Pixel
 * Pixel - a contract for non-fungible pixels.
 */
contract Pixel is TradeableERC721Token {  
  
  string private baseURI;

  constructor(address _proxyRegistryAddress) TradeableERC721Token("Pixel", "PXL", _proxyRegistryAddress) public { 
    baseURI = "https://last-pixel-api.herokuapp.com/api/pixel/";
   }

  function baseTokenURI() public view returns (string) {
    return baseURI;
  }

  function setBaseTokenURI(string _newBaseURI) external onlyOwner {
    baseURI = _newBaseURI;
  }
  
}

