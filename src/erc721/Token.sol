// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";

/// @author Patrick O'Dacre
/// @title Simple ERC721 Implementation
contract Token is IERC721 {

    error ZeroAddress();
    error TokenNotFound(uint);
    error TokenExists(uint);
    error NotOwner(address);
    error Unauthorized(address);
    error NotERC721Receiver(address);

    /// @notice tokenId => owner
    mapping(uint => address) internal _ownerOf;

    /// @notice owner => total number of tokens
    mapping(address => uint) internal _balanceOf;

    /// @notice tokenId => approved address
    mapping(uint => address) internal _approvals;

    /// @notice owner => operator => is_approved
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /// @notice Retrieve the owner for a token
    /// @param id The token id
    /// @return owner the address of the owner
    function ownerOf(uint id) external view returns (address) {
        address owner = _ownerOf[id];

        // gas: 2544
        // require(address(0) != owner, "not exist");

        // custom errors are cheaper
        // gas: 2530
        if (address(0) == owner) {
            revert TokenNotFound(id);
        }

        return owner;
    }

    /// @notice Retrieve the number of tokens owned by owner
    /// @param owner Owner's address
    /// @return balance Number of ERC721 tokens owned
    function balanceOf(address owner) external view returns (uint) {
        if (address(0) == owner) {
            revert ZeroAddress();
        }

        return _balanceOf[owner];
    }

    /// @notice Grant approval to operator for any transfers
    /// @dev Revoke when the Token is burned or transferred
    /// @param operator Address of the approved
    /// @param approved is_approved
    function setApprovalForAll(address operator, bool approved) external {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /// @notice Get address of approved operator
    /// @param id Token id
    /// @return approved Address of the approved operator
    function getApproved(uint id) external view returns (address) {

        if (address(0) == _ownerOf[id]) {
            revert TokenNotFound(id);
        }

        return _approvals[id];
    }

    /// @notice Approve address to transfer token
    /// @param to Operator address
    /// @param id Token Id
    function approve(address to, uint id) external {
        if (address(0) == to) {
            revert ZeroAddress();
        }

        if (msg.sender != _ownerOf[id]) {
            revert NotOwner(msg.sender);
        }

        _approvals[id] = to;

        emit Approval(msg.sender, to, id);
    }

    /// @notice Transfer token of Id from _from to _to
    /// @param from From address
    /// @param to To address
    /// @param id Token id
    function transferFrom(address from, address to, uint id) public {

        if (address(0) == to || address(0) == from) {
            revert ZeroAddress();
        }

        address owner = _ownerOf[id];

        if (address(0) == owner) {
            revert TokenNotFound(id);
        }

        if (from != owner) {
            revert NotOwner(from);
        }

        if (msg.sender != owner &&
            msg.sender != _approvals[id] &&
            !isApprovedForAll[from][msg.sender]) {
            revert Unauthorized(msg.sender);
        }

        delete _approvals[id];
        _ownerOf[id] = to;
        _balanceOf[from] -= 1;
        _balanceOf[to] += 1;

        emit Transfer(from, to, id);

    }

    /// @notice Transfer token of Id from _from to _to
    /// @dev reverts if receiver does not implement IERC721Receiver
    /// @param from From address
    /// @param to To address
    /// @param id Token id
    function safeTransferFrom(address from, address to, uint id) external {
        // if to is a contract
        if (to.code.length > 0) {
            bytes4 data = IERC721Receiver(to).onERC721Received(msg.sender, from, id, "");

            if (IERC721Receiver.onERC721Received.selector != data) {
                revert NotERC721Receiver(to);
            }
        }

        transferFrom(from, to, id);
    }

    /// @notice Transfer token of Id from _from to _to
    /// @dev reverts if receiver does not implement IERC721Receiver
    /// @param from From address
    /// @param to To address
    /// @param id Token id
    function safeTransferFrom(
        address from,
        address to,
        uint id,
        bytes calldata data
    ) external {

        // if to is a contract
        if (to.code.length > 0) {
            bytes4 _data = IERC721Receiver(to).onERC721Received(msg.sender, from, id, data);

            if (IERC721Receiver.onERC721Received.selector != _data) {
                revert NotERC721Receiver(to);
            }
        }

        transferFrom(from, to, id);
    }

    /// @notice Mint Token
    /// @param to Recipient's address
    /// @param id Token id
    function mint(address to, uint id) external {
        if (address(0) == to) {
            revert ZeroAddress();
        }

        if (address(0) != _ownerOf[id]) {
            revert TokenExists(id);
        }

        _ownerOf[id] = msg.sender;
        _balanceOf[msg.sender] += 1;

        emit Transfer(address(0), msg.sender, id);
    }

    /// @notice Burn Token
    /// @param id Token id
    function burn(uint id) external {
        address owner = _ownerOf[id];
        if (address(0) == owner) {
            revert TokenNotFound(id);
        }

        if (msg.sender != owner) {
            revert NotOwner(msg.sender);
        }

        delete _approvals[id];
        delete _ownerOf[id];
        _balanceOf[owner] -= 1;

        if (0 == _balanceOf[owner]) {
            delete isApprovedForAll[owner][msg.sender];
        }

        emit Transfer(msg.sender, address(0), id);
    }

    /// @notice Notify calling contracts of the Interfaces this contract supports
    function supportsInterface(
        bytes4 interfaceId
    ) external pure returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }


}
