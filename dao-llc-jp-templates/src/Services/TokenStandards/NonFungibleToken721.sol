// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;
 
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Counters } from "@openzeppelin/contracts/utils/Counters.sol";

interface ErrorNonFungibleToken721 {
    error ErrTokenLocked(bool locked_);
}

contract NonFungibleToken721 is ERC721, ErrorNonFungibleToken721 {
    using Counters for Counters.Counter;

    address private _admin;
    // TODO: paramの変更をする
    bool private _isLocked;
    string public _baseURI;
    string public _baseExtension = ".json";

    Counters.Counter private _tokenIdCounter;

    /// sbt_ フラグがtrueの場合、トークンの転送や承認を禁止します（SBT化する）
    constructor(string memory name_, string memory symbol_, string memory baseURI_, bool sbt_) ERC721(name_, symbol_) {
        _admin = msg.sender;
        _tokenIdCounter.increment();
        _baseURI = baseURI_;
        _isLocked = sbt_;
    }

    function mint() external {
        uint256 _tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _mint(msg.sender, _tokenId);
    }

    function tokenURI(uint256 tokenId_) public view virtual override returns (string memory) {
        require(_exists(tokenId_), "Error: NonFungibleToken721/URI-Non-Existent");
        return string(abi.encodePacked(ERC721.tokenURI(tokenId_), _baseExtension));
    }

    function _baseURI() internal view virtual override returns (string memory baseURI_) {
        baseURI_ = _baseURI;
    }

    /// Note: SBTケースで、転送や承認を禁止する機能群
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override checkLock {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override checkLock {
        super.safeTransferFrom(from, to, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public override checkLock {
        super.transferFrom(from, to, tokenId);
    }

    function approve(address approved, uint256 tokenId) public override checkLock {
        super.approve(approved, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public override checkLock {
        super.setApprovalForAll(operator, approved);
    }

    modifier checkLock() {
        if (_isCheckLock()) revert ErrTokenLocked();
        _;
    }

    function _isCheckLock() internal returns(bool locked_) {
        locked_ = _isLocked;
    }

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Error: NonFungibleToken721/Only-Owner");
        _;
    }
}
