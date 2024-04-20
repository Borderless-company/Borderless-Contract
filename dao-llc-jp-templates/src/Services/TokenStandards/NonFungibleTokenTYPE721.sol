// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;
 
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {EventNonFungibleTokenTYPE721} from "src/interfaces/Services/TokenService/TokenStandards/NonFungibleTokenTYPE721/EventNonFungibleTokenTYPE721.sol";
import {ErrorNonFungibleTokenTYPE721} from "src/interfaces/Services/TokenService/TokenStandards/NonFungibleTokenTYPE721/ErrorNonFungibleTokenTYPE721.sol";

// interface INonFungibleTokenTYPE721 {
//     // function mint() external;
//     function setupPublicSale(uint256 saleStart_, uint256 saleEnd_) external;
//     function activateTokenSale() external returns(bool active_);
//     function deactivateTokenSale() external returns(bool active_);
// }

contract NonFungibleTokenTYPE721 is ERC721, EventNonFungibleTokenTYPE721, ErrorNonFungibleTokenTYPE721 {
    address private _admin;
    uint256 private _lastTokenID;
    mapping(address account_ => bool minted_) private _holders;
    string private _tokenBaseURI;
    string private _baseExtension = ".json";
    bool private _isLocked;
    bool private _saleActive;
    uint256 private _saleStart;
    uint256 private _saleEnd;
  
    /// sbt_ フラグがtrueの場合、トークンの転送や承認を禁止します（SBT化する）
    // TODO: 業執行社員・非業務執行社員トークンは一つしか有すことができない仕組みつくり
    constructor(
        address admin_,
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        bool sbt_
        ) ERC721(name_, symbol_) {
            if(sbt_) _isLocked = true;
            if(bytes(baseURI_).length > 0) _tokenBaseURI = baseURI_;
            _admin = admin_;
    }

    // -- utils -- //
    function _currentTokenID() internal view returns(uint256 tokenId_) {
        tokenId_ = _lastTokenID;
    }

    function _incrementLastID(uint256 currentTokenID_) internal returns(bool updated_, uint256 tokenID_){
        uint256 _currentID = currentTokenID_;
        _lastTokenID++;
        uint256 _updateID = _currentTokenID();

        if(_currentID + 1 == _updateID) (updated_, tokenID_) = (true, _updateID);
    }

    // -- 標準機能 -- //

    function mint() external validateCall() {
        if(_holoderOf(msg.sender)) revert AlreadyMinted(msg.sender, name(), symbol());
        (bool updated_, uint256 tokenID_)= _incrementLastID(_currentTokenID());

        if(!updated_) revert DoNotMint(msg.sender, name(), symbol());
        _mint(msg.sender, tokenID_);
        
        _holders[msg.sender] = true;
    }

    function mint(address to_) external onlyAdmin() {
        if(_holoderOf(to_)) revert AlreadyMinted(to_, name(), symbol());
        (bool updated_, uint256 tokenID_)= _incrementLastID(_currentTokenID());

        if(!updated_) revert DoNotMint(to_, name(), symbol());
        _mint(to_, tokenID_);
        
        _holders[to_] = true;
    }

    function _holoderOf(address account_) internal view returns(bool minted_) {
        minted_ = _holders[account_];
    }

    function tokenURI(uint256 tokenId_) public view virtual override returns (string memory) {
        require(ownerOf(tokenId_) == msg.sender, "Error: NonFungibleToken721/Only-TokenHolder");
        return string(abi.encodePacked(ERC721.tokenURI(tokenId_), _baseExtension));
    }
    
    function _baseURI() internal view virtual override returns (string memory baseURI_) {
        baseURI_ = _tokenBaseURI;
    }

    /// Note: SBTケースで、転送や承認を禁止する機能群
    // function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public checkLock {
    //     super.safeTransferFrom(from, to, tokenId, data);
    // }

    // function safeTransferFrom(address from, address to, uint256 tokenId) public checkLock {
    //     super.safeTransferFrom(from, to, tokenId);
    // }

    function transferFrom(address from, address to, uint256 tokenId) public override checkLock {
        if(_holoderOf(to)) revert AlreadyMinted(to_, name(), symbol());
        super.transferFrom(from, to, tokenId);

        _holders[from] = false;
        _holders[to] = true;
    }

    function approve(address approved, uint256 tokenId) public override checkLock {
        super.approve(approved, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public override checkLock {
        super.setApprovalForAll(operator, approved);
    }

    // -- Setting: Token Public Sale -- //
    function setupPublicSale(uint256 saleStart_, uint256 saleEnd_) external onlyAdmin {
        if(saleEnd_ < block.timestamp) revert InvalidTime(saleStart_, saleEnd_);
        if(saleStart_ > saleEnd_) revert InvalidTime(saleStart_, saleEnd_);

        emit SetPublicSale(saleStart_, saleEnd_);
        _saleStart = saleStart_;
        _saleEnd = saleEnd_;
    }

    function activateTokenSale() external onlyAdmin returns(bool active_){
        if(_saleActive) revert AlreadySaleActivate(_saleActive);

        _saleActive = true;
        emit ActivateTokenSale(name(), symbol(), _saleActive);

        active_ = _saleActive;
    }

    function deactivateTokenSale() external onlyAdmin returns(bool active_){
        if(!_saleActive) revert AlreadySaleDeactivate(_saleActive);

        _saleActive = false;
        emit DeactivateTokenSale(name(), symbol(), _saleActive);

        active_ = !_saleActive;
    }

    modifier checkLock() {
        if (_isCheckLock()) revert TokenLocked(_isLocked);
        _;
    }

    function _isCheckLock() internal view returns(bool locked_) {
        locked_ = _isLocked;
    }

    // -- Modifier -- //

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Error: NonFungibleTokenTYPE721/Only-Admin");
        _;
    }

    modifier validateCall() {
        require(_validateCall(), "Error: NonFungibleTokenTYPE721/Invalid-Caller");
        _;
    }

    function _validateCall() internal view returns(bool called_) {
        if(msg.sender == _admin || _checkSale()) called_ = true;
    }

    function _checkSale() internal view returns(bool active_) {
        if(_saleActive || (_saleStart <= block.timestamp && _saleEnd >= block.timestamp)) active_ = true;
    }
}
