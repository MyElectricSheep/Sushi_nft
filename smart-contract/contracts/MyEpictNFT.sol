// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// We first import some OpenZeppelin Contracts.
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import { Base64 } from "./libraries/Base64.sol";

// We inherit the contract we imported. This means we'll have access
// to the inherited contract's methods.
contract MyEpicNFT is ERC721URIStorage {
  // Magic given to us by OpenZeppelin to help us keep track of tokenIds.
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  // This is our SVG code. All we need to change are the words that will be displayed. Everything else stays the same.
  // baseSvg variable here that all our NFTs can use:
  string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 18px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='90%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  // https://www.thesaurus.com/browse/delicious
  string[] firstWords = ["Delicious", "Appetizing", "Delectable", "Delightful", "Enticing", "Exquisite", "Heavenly", "Luscious", "Pleasant", "Rich", "Savory", "Spicy", "Sweet", "Tasty", "Tempting", "Yummy"];
  // https://gurunavi.com/en/japanfoodie/2017/05/types-of-sushi.html?__ngt__=TT12b2278e5005ac1e4ae0e0lZ5QBi6IudZ_F82vT-mszV
  string[] secondWords = ["Ahi", "Aji", "Amaebi", "Anago", "Aoyagi", "Bincho", "Katsuo", "Ebi", "Hamachi", "HamachiToro", "Hirame", "Hokigai", "Hotate", "Ika", "Ikura", "Iwashi", "Kani", "Kanpachi", "Maguro", "Saba", "Sake", "SakeToro", "Tai", "Tako", "Tamago", "Toro", "Tsubugai", "UmiMasu", "Unagi", "Uni"];
    // https://delishably.com/meat-dishes/The-Different-Kinds-of-Sushi
  string[] thirdWords = ["Maki_Sushi", "Gunkan_Maki", "Temaki", "Nare_Sushi", "Nigiri", "Oshi_Sushi", "Sasa_Sushi", "Kakinoha_Sushi", "Temari", "Chirashi_Sushi", "Inari_Sushi"];

  // We need to pass the name of our NFTs token and its symbol.
  constructor() ERC721 ("SquareNFT", "SQUARE") {
    console.log("This is my NFT contract. Woah!");
  }

  // Create a function to randomly pick a word from each array.
  function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
    // Seed the random generator. More on this in the lesson. 
    uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
    // Squash the # between 0 and the length of the array to avoid going out of bounds.
    rand = rand % firstWords.length;
    return firstWords[rand];
  }

  function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
    rand = rand % secondWords.length;
    return secondWords[rand];
  }

  function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
    rand = rand % thirdWords.length;
    return thirdWords[rand];
  }

  function random(string memory input) internal pure returns(uint256) {
      return uint256(keccak256(abi.encodePacked(input)));
  }

  // A function our user will hit to get their NFT.
  function makeAnEpicNFT() public {
     // Get the current tokenId, this starts at 0.
    uint256 newItemId = _tokenIds.current();

    // Go and 'randomly' grab one word from each of the three arrays.
    string memory first = pickRandomFirstWord(newItemId);
    string memory second = pickRandomSecondWord(newItemId);
    string memory third = pickRandomThirdWord(newItemId);
    string memory combinedWords = string(abi.encodePacked(unicode"🌟", first, "_" ,second, "_" , third, unicode"🍣"));

    // Concatenate it all together, and then close the <text> and <svg> tags.
    string memory finalSvg = string(abi.encodePacked(baseSvg, combinedWords, "</text></svg>"));

    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked('{"name": "',combinedWords,'", "description": "A highly acclaimed NFT collection from Electric Sheep.", "image": "data:image/svg+xml;base64,',Base64.encode(bytes(finalSvg)),'"}'
          )
        )
      )
    );

    string memory finalTokenUri = string(
      abi.encodePacked("data:application/json;base64,", json)
    );


    console.log("\n--------------------");
    // console.log(finalTokenUri);
    console.log(
          string(
        abi.encodePacked(
            "https://nftpreview.0xdev.codes/?code=",
            finalTokenUri
        )
     )
    );
    console.log("--------------------\n");


    _safeMint(msg.sender, newItemId);
  
    _setTokenURI(newItemId, finalTokenUri);
  
    _tokenIds.increment();
    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
  }
}
