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
contract sushiNFT is ERC721URIStorage {
  // Magic given to us by OpenZeppelin to help us keep track of tokenIds.
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  // This is our base SVG code:
  string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 640 480'><style>.base { fill: black; font-family: serif; font-size: 28px; }</style><rect width='100%' height='100%' fill='url(#wave)' fill-opacity='0.6'/><defs><pattern id='wave' x='0' y='0' width='56' height='28' patternUnits='userSpaceOnUse'><path fill='#8cd790' d='M56 26v2h-7.75c2.3-1.27 4.94-2 7.75-2zm-26 2a2 2 0 1 0-4 0h-4.09A25.98 25.98 0 0 0 0 16v-2c.67 0 1.34.02 2 .07V14a2 2 0 0 0-2-2v-2a4 4 0 0 1 3.98 3.6 28.09 28.09 0 0 1 2.8-3.86A8 8 0 0 0 0 6V4a9.99 9.99 0 0 1 8.17 4.23c.94-.95 1.96-1.83 3.03-2.63A13.98 13.98 0 0 0 0 0h7.75c2 1.1 3.73 2.63 5.1 4.45 1.12-.72 2.3-1.37 3.53-1.93A20.1 20.1 0 0 0 14.28 0h2.7c.45.56.88 1.14 1.29 1.74 1.3-.48 2.63-.87 4-1.15-.11-.2-.23-.4-.36-.59H26v.07a28.4 28.4 0 0 1 4 0V0h4.09l-.37.59c1.38.28 2.72.67 4.01 1.15.4-.6.84-1.18 1.3-1.74h2.69a20.1 20.1 0 0 0-2.1 2.52c1.23.56 2.41 1.2 3.54 1.93A16.08 16.08 0 0 1 48.25 0H56c-4.58 0-8.65 2.2-11.2 5.6 1.07.8 2.09 1.68 3.03 2.63A9.99 9.99 0 0 1 56 4v2a8 8 0 0 0-6.77 3.74c1.03 1.2 1.97 2.5 2.79 3.86A4 4 0 0 1 56 10v2a2 2 0 0 0-2 2.07 28.4 28.4 0 0 1 2-.07v2c-9.2 0-17.3 4.78-21.91 12H30zM7.75 28H0v-2c2.81 0 5.46.73 7.75 2zM56 20v2c-5.6 0-10.65 2.3-14.28 6h-2.7c4.04-4.89 10.15-8 16.98-8zm-39.03 8h-2.69C10.65 24.3 5.6 22 0 22v-2c6.83 0 12.94 3.11 16.97 8zm15.01-.4a28.09 28.09 0 0 1 2.8-3.86 8 8 0 0 0-13.55 0c1.03 1.2 1.97 2.5 2.79 3.86a4 4 0 0 1 7.96 0zm14.29-11.86c1.3-.48 2.63-.87 4-1.15a25.99 25.99 0 0 0-44.55 0c1.38.28 2.72.67 4.01 1.15a21.98 21.98 0 0 1 36.54 0zm-5.43 2.71c1.13-.72 2.3-1.37 3.54-1.93a19.98 19.98 0 0 0-32.76 0c1.23.56 2.41 1.2 3.54 1.93a15.98 15.98 0 0 1 25.68 0zm-4.67 3.78c.94-.95 1.96-1.83 3.03-2.63a13.98 13.98 0 0 0-22.4 0c1.07.8 2.09 1.68 3.03 2.63a9.99 9.99 0 0 1 16.34 0z'/></pattern></defs><g stroke-width='3'><line stroke='#000' y2='323.77728' x2='562.27463' y1='311.49999' x1='562.27463' fill='none'/><line transform='rotate(-90 557.639 322.439)' stroke='#000' y2='328.57771' x2='557.6395' y1='316.30041' x1='557.6395' fill='none'/></g><g transform='rotate(-180 92.639 162.639)' stroke-width='3'><line stroke='#000' y2='168.7773' x2='97.27418' y1='156.50001' x1='97.27418' fill='none'/><line transform='rotate(-90 92.639 167.439)' stroke='#000' y2='173.57772' x2='92.63906' y1='161.30042' x1='92.63906' fill='none'/></g>";

  // https://www.thesaurus.com/browse/delicious
  string[] firstWords = ["Delicious", "Appetizing", "Delectable", "Delightful", "Enticing", "Exquisite", "Heavenly", "Luscious", "Pleasant", "Rich", "Savory", "Spicy", "Sweet", "Tasty", "Tempting", "Yummy"];
  // https://gurunavi.com/en/japanfoodie/2017/05/types-of-sushi.html?__ngt__=TT12b2278e5005ac1e4ae0e0lZ5QBi6IudZ_F82vT-mszV
  string[] secondWords = ["Ahi", "Aji", "Amaebi", "Anago", "Aoyagi", "Bincho", "Katsuo", "Ebi", "Hamachi", "HamachiToro", "Hirame", "Hokigai", "Hotate", "Ika", "Ikura", "Iwashi", "Kani", "Kanpachi", "Maguro", "Saba", "Sake", "SakeToro", "Tai", "Tako", "Tamago", "Toro", "Tsubugai", "UmiMasu", "Unagi", "Uni"];
    // https://delishably.com/meat-dishes/The-Different-Kinds-of-Sushi
  string[] thirdWords = ["Maki_Sushi", "Gunkan_Maki", "Temaki", "Nare_Sushi", "Nigiri", "Oshi_Sushi", "Sasa_Sushi", "Kakinoha_Sushi", "Temari", "Chirashi_Sushi", "Inari_Sushi"];

  event NewSushiNFTMinted(address sender, uint256 tokenId, uint256 numberOfNFTs);

  // We need to pass the name of our NFTs token and its symbol.
  constructor() ERC721 ("sushiNFT", "SUSHI") {
    console.log("sushiNFT contract initialized");
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

  function howManyNFTs() public view returns(uint256) {
      return _tokenIds.current();
  }

  // A function our user will hit to get their NFT.
  function makeAnEpicNFT() public {
    // require(balanceOf(msg.sender) == 0, 'Each address may only own one sushiNFT');
    require(balanceOf(msg.sender) < 2, 'Each address may only own one sushiNFT');
    require(_tokenIds.current() < 366, 'Only 365 sushiNFT can be minted!');


     // Get the current tokenId, this starts at 0.
    uint256 newItemId = _tokenIds.current();

    // Go and 'randomly' grab one word from each of the three arrays.
    string memory first = pickRandomFirstWord(newItemId);
    string memory second = pickRandomSecondWord(newItemId);
    string memory third = pickRandomThirdWord(newItemId);
    string memory combinedWords = string(abi.encodePacked(unicode"🌟", first, "_" ,second, "_" , third, unicode"🍣"));

    string memory verseOne = string(abi.encodePacked("<text x='50%' y='40%' class='base' dominant-baseline='middle' text-anchor='middle'>", first, "</text>"));
    string memory verseTwo = string(abi.encodePacked("<text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>", second, "</text>"));
    string memory verseThree = string(abi.encodePacked("<text x='50%' y='60%' class='base' dominant-baseline='middle' text-anchor='middle'>", third, "</text>"));

    // Concatenate it all together, and then close the <text> and <svg> tags.
    string memory finalSvg = string(abi.encodePacked(baseSvg, verseOne, verseTwo, verseThree, "</svg>"));

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

    // Send an event that we can capture in the client
    emit NewSushiNFTMinted(msg.sender, newItemId, _tokenIds.current());
  }
}
