pragma solidity ^0.4.24;

import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Factory.sol";
import "./Pixel.sol";
import "./Strings.sol";

contract PixelFactory is Factory, Ownable {
  using Strings for string;

  address public proxyRegistryAddress;
  address public nftAddress;
  string public baseURI = "https://last-pixel-api.herokuapp.com/api/factory/";
  uint singlePixelOptionMinted;
  uint multiplePixelsOptionMinted;

  /**
   * Enforce the existence of only 10000 pixels.
   */
  uint PIXEL_SUPPLY = 10000;

  /**
   * Two different options for minting Pixels.
   */
  uint NUM_OPTIONS = 2;
  uint SINGLE_PIXEL_OPTION = 0;
  uint MULTIPLE_PIXEL_OPTION = 1;
  uint NUM_PIXELS_IN_MULTIPLE_PIXEL_OPTION = 25;
  uint SINGLE_PIXEL_OPTION_ALLOCATED = 5000;
  uint MULTIPLE_PIXELS_OPTION_ALLOCATED = 5000;

  constructor(address _proxyRegistryAddress, address _nftAddress) public {
    proxyRegistryAddress = _proxyRegistryAddress;
    nftAddress = _nftAddress;

  }

  function name() external view returns (string) {
    return "Last Pixel Game Pixel Item Sale";
  }

  function symbol() external view returns (string) {
    return "LPC";
  }

  function supportsFactoryInterface() public view returns (bool) {
    return true;
  }

  function numOptions() public view returns (uint) {
    return NUM_OPTIONS;
  }
  
  function mint(uint _optionId, address _toAddress) public {
    // Must be sent from the owner proxy or owner.
    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    assert(proxyRegistry.proxies(owner()) == msg.sender || owner() == msg.sender);
    require(canMint(_optionId));

    Pixel openSeaPixel = Pixel(nftAddress);
    if (_optionId == SINGLE_PIXEL_OPTION) {
      openSeaPixel.mintTo(_toAddress);
      singlePixelOptionMinted++;
    } else if (_optionId == MULTIPLE_PIXEL_OPTION) {
      for (uint i = 0; i < NUM_PIXELS_IN_MULTIPLE_PIXEL_OPTION; i++) {
        openSeaPixel.mintTo(_toAddress);
        multiplePixelsOptionMinted++;
      }
    }
  }

  function canMint(uint _optionId) public view returns (bool) {
    if (_optionId >= NUM_OPTIONS) {
      return false;
    }

    Pixel openSeaPixel = Pixel(nftAddress);
    uint pixelSupply = openSeaPixel.totalSupply();

    uint numItemsAllocated = 0;
    if (_optionId == SINGLE_PIXEL_OPTION) {
      numItemsAllocated = 1;
      return singlePixelOptionMinted <= (5000 - numItemsAllocated);
    } else if (_optionId == MULTIPLE_PIXEL_OPTION) {
      numItemsAllocated = NUM_PIXELS_IN_MULTIPLE_PIXEL_OPTION;
      return multiplePixelsOptionMinted <= (MULTIPLE_PIXELS_OPTION_ALLOCATED - numItemsAllocated);
    } 
  }
  
  function tokenURI(uint _optionId) public view returns (string) {
    return Strings.strConcat(
        baseURI,
        Strings.uint2str(_optionId)
    );
  }

  /**
   * Hack to get things to work automatically on OpenSea.
   * Use transferFrom so the frontend doesn't have to worry about different method names.
   */
  function transferFrom(address _from, address _to, uint _tokenId) public {
    mint(_tokenId, _to);
  }

  /**
   * Hack to get things to work automatically on OpenSea.
   * Use isApprovedForAll so the frontend doesn't have to worry about different method names.
   */
  function isApprovedForAll(
    address _owner,
    address _operator
  )
    public
    view
    returns (bool)
  {
    if (owner() == _owner && _owner == _operator) {
      return true;
    }

    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    if (owner() == _owner && proxyRegistry.proxies(_owner) == _operator) {
      return true;
    }

    return false;
  }

  /**
   * Hack to get things to work automatically on OpenSea.
   * Use isApprovedForAll so the frontend doesn't have to worry about different method names.
   */
  function ownerOf(uint _tokenId) public view returns (address _owner) {
    return owner();
  }
}