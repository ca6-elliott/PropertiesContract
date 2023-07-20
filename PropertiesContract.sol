// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Property {
    
    struct PropertyListing {
        uint256 propertyId;
        address owner;
        uint256 price;
        uint256 leasePrice;
        bool isLeased;
        address leaseHolder;
        bool isForSale;
        bool isSold;
    }
    
    mapping (uint256 => PropertyListing) public propertyListings;
    uint256 public numListings;
    
    event PropertyForSale(uint256 indexed propertyId, address indexed owner, uint256 price);
    event PropertySold(uint256 indexed propertyId, address indexed owner, address indexed buyer, uint256 price);
    event PropertyLeased(uint256 indexed propertyId, address indexed owner, address indexed leaseHolder, uint256 leasePrice);
    event LeaseEnded(uint256 indexed propertyId, address indexed owner, address indexed leaseHolder);
    
    function createListing(uint256 price, uint256 leasePrice) public returns (uint256) {
        require(price > 0, "Price cannot be zero");
        require(leasePrice > 0, "Lease price cannot be zero");
        
        numListings++;
        propertyListings[numListings] = PropertyListing(numListings, msg.sender, price, leasePrice, false, address(0), true, false);
        
        emit PropertyForSale(numListings, msg.sender, price);
        
        return numListings;
    }
    
    function buyProperty(uint256 propertyId) public payable {
        require(propertyListings[propertyId].isForSale, "Property is not for sale");
        require(!propertyListings[propertyId].isSold, "Property has already been sold");
        require(msg.value >= propertyListings[propertyId].price, "Insufficient funds");
        
        address payable seller = payable(propertyListings[propertyId].owner);
        seller.transfer(msg.value);
        
        propertyListings[propertyId].isForSale = false;
        propertyListings[propertyId].isSold = true;
        propertyListings[propertyId].owner = msg.sender;
        
        emit PropertySold(propertyId, seller, msg.sender, msg.value);
    }
    
    function leaseProperty(uint256 propertyId, uint256 duration) public payable {
        require(propertyListings[propertyId].isForSale == false, "Property is for sale and cannot be leased");
        require(!propertyListings[propertyId].isLeased, "Property is already leased");
        require(msg.value >= propertyListings[propertyId].leasePrice * duration, "Insufficient funds");
        
        address payable owner = payable(propertyListings[propertyId].owner);
        owner.transfer(msg.value);
        
        propertyListings[propertyId].isLeased = true;
        propertyListings[propertyId].leaseHolder = msg.sender;
        
        emit PropertyLeased(propertyId, owner, msg.sender, msg.value);
    }
    
    function endLease(uint256 propertyId) public {
        require(propertyListings[propertyId].isLeased, "Property is not leased");
        require(msg.sender == propertyListings[propertyId].leaseHolder, "Only the lease holder can end the lease");
        
        propertyListings[propertyId].isLeased = false;
        propertyListings[propertyId].leaseHolder = address(0);
        
        emit LeaseEnded(propertyId, propertyListings[propertyId].owner, msg.sender);
    }
    
}
