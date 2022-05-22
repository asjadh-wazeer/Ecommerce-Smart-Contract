// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract Ecommerce {
    struct Product { //We have a product of type struct
        string title;
        string desc;
        address payable seller;
        uint productId;
        uint price;
        address buyer;
        bool delivered;
    }
    //Now we will create an array. This array will be of type product
    Product[] public products;

    //Let's create the manager of the smart contract for the destroy function
    address payable public manager;
    //Initialize the manager address by using constructor


    bool destroyed=false;
    modifier isNotDestroyed {
        require(!destroyed, "Contract does not exist");
        _;
    } //Now we will use isNotDestroyed modifier in all our fuction



    constructor() {
        manager=payable(msg.sender);
    }



    uint counter = 1;


    //Create some events

    //this will be emitted when product will be registered
    event registered(string title, uint productId, address seller);
    //this will be emitted when product has been bought
    event bought(uint productId, address buyer);
    event delivered(uint productId);

    //Now we want to eimt -> I emitted inside the registerProduct contract





    function registerProduct( string memory _title, string memory _desc, uint _price) public {
        require(_price >0, "Price should be greater than zero");

        //Now we will create variable tempProduct of product type
        Product memory tempProduct; //This will store everything about product that we are trying to the register

        //insert element to struct
        tempProduct.title =_title;
        tempProduct.desc =_desc;
        tempProduct.price =_price * 10**18; //converting ether into whei
        tempProduct.seller=payable(msg.sender); //seller of the product -> Since we are going to pay this msg.sender -> Bcz he is seelling the product
        //we have to pay to seller. so we have to make this msg.sender, payable msg.sender, so we can transfer ether to this address

        tempProduct.productId=counter; //we are going to store our product id are new variable call counter variable which will productId

        
        //Now we will push all of the information to products array
        products.push(tempProduct);
        counter++; //Someone else try to register the product, that product id should be different product id that was registerd before


        emit registered(_title, tempProduct.productId, msg.sender);//what we are going to emited? title of the product....
    }

    function buy(uint _productId) payable public isNotDestroyed { 
        require(products[_productId-1].price==msg.value, "Please pay the exact the exact price"); //_productId-1 --> id=index-1 //Here we are using products array
        require(products[_productId-1].seller!=msg.sender, "seller cannot be buyer of the product");//The person who is actually selling the product, should not buy the product

        //If there are 2 conditions satisfied, then we are going tomake hime the buyer of the product
        products[_productId-1].buyer=msg.sender;
        emit bought(_productId, msg.sender);
    }

    function delivery(uint _productId) public isNotDestroyed{
        //First of all we want to check you are the buyer of the product or not
        require(products[_productId-1].buyer==msg.sender, "Only buyer can confirm this");
        products[_productId-1].delivered=true;

        //Now we are going to transfer funds to the seller
        products[_productId-1].seller.transfer(products[_productId-1].price);


        emit delivered(_productId);
    }



    //Now we want to create events



    //Let's make the function destroy
    // function destroy() public {
    //     require(msg.sender==manager,"Only manager can call this function");//msg.sender actuallly manager or not //Only manager of the contract can call the destroy function
    //     selfdestruct(manager);
    // }

    function destroy() public isNotDestroyed{
        require(manager==msg.sender);
        manager.transfer(address(this).balance);
        destroyed=true;
    }

    fallback() payable external {
        payable(msg.sender).transfer(msg.value);
    }
    
}