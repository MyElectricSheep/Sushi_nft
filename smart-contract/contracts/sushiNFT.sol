// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import { Base64 } from "./libraries/Base64.sol";

contract sushiNFT is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 640 480'><style>.base { fill: black; font-family: serif; font-size: 28px; }</style><rect width='100%' height='100%' fill='url(#wave)' fill-opacity='0.6'/><defs><pattern id='wave' x='0' y='0' width='56' height='28' patternUnits='userSpaceOnUse'><path fill='";
  string patternSvg = "' d='M56 26v2h-7.75c2.3-1.27 4.94-2 7.75-2zm-26 2a2 2 0 1 0-4 0h-4.09A25.98 25.98 0 0 0 0 16v-2c.67 0 1.34.02 2 .07V14a2 2 0 0 0-2-2v-2a4 4 0 0 1 3.98 3.6 28.09 28.09 0 0 1 2.8-3.86A8 8 0 0 0 0 6V4a9.99 9.99 0 0 1 8.17 4.23c.94-.95 1.96-1.83 3.03-2.63A13.98 13.98 0 0 0 0 0h7.75c2 1.1 3.73 2.63 5.1 4.45 1.12-.72 2.3-1.37 3.53-1.93A20.1 20.1 0 0 0 14.28 0h2.7c.45.56.88 1.14 1.29 1.74 1.3-.48 2.63-.87 4-1.15-.11-.2-.23-.4-.36-.59H26v.07a28.4 28.4 0 0 1 4 0V0h4.09l-.37.59c1.38.28 2.72.67 4.01 1.15.4-.6.84-1.18 1.3-1.74h2.69a20.1 20.1 0 0 0-2.1 2.52c1.23.56 2.41 1.2 3.54 1.93A16.08 16.08 0 0 1 48.25 0H56c-4.58 0-8.65 2.2-11.2 5.6 1.07.8 2.09 1.68 3.03 2.63A9.99 9.99 0 0 1 56 4v2a8 8 0 0 0-6.77 3.74c1.03 1.2 1.97 2.5 2.79 3.86A4 4 0 0 1 56 10v2a2 2 0 0 0-2 2.07 28.4 28.4 0 0 1 2-.07v2c-9.2 0-17.3 4.78-21.91 12H30zM7.75 28H0v-2c2.81 0 5.46.73 7.75 2zM56 20v2c-5.6 0-10.65 2.3-14.28 6h-2.7c4.04-4.89 10.15-8 16.98-8zm-39.03 8h-2.69C10.65 24.3 5.6 22 0 22v-2c6.83 0 12.94 3.11 16.97 8zm15.01-.4a28.09 28.09 0 0 1 2.8-3.86 8 8 0 0 0-13.55 0c1.03 1.2 1.97 2.5 2.79 3.86a4 4 0 0 1 7.96 0zm14.29-11.86c1.3-.48 2.63-.87 4-1.15a25.99 25.99 0 0 0-44.55 0c1.38.28 2.72.67 4.01 1.15a21.98 21.98 0 0 1 36.54 0zm-5.43 2.71c1.13-.72 2.3-1.37 3.54-1.93a19.98 19.98 0 0 0-32.76 0c1.23.56 2.41 1.2 3.54 1.93a15.98 15.98 0 0 1 25.68 0zm-4.67 3.78c.94-.95 1.96-1.83 3.03-2.63a13.98 13.98 0 0 0-22.4 0c1.07.8 2.09 1.68 3.03 2.63a9.99 9.99 0 0 1 16.34 0z'/></pattern></defs><g stroke-width='3'><line stroke='#000' y2='323.77728' x2='562.27463' y1='311.49999' x1='562.27463' fill='none'/><line transform='rotate(-90 557.639 322.439)' stroke='#000' y2='328.57771' x2='557.6395' y1='316.30041' x1='557.6395' fill='none'/></g><g transform='rotate(-180 92.639 162.639)' stroke-width='3'><line stroke='#000' y2='168.7773' x2='97.27418' y1='156.50001' x1='97.27418' fill='none'/><line transform='rotate(-90 92.639 167.439)' stroke='#000' y2='173.57772' x2='92.63906' y1='161.30042' x1='92.63906' fill='none'/></g>";

  // Random sushi words
  string[] firstWords = ["Delicious", "Appetizing", "Delectable", "Delightful", "Enticing", "Exquisite", "Heavenly", "Luscious", "Pleasant", "Rich", "Savory", "Spicy", "Sweet", "Tasty", "Tempting", "Yummy"];
  string[] secondWords = ["Ahi", "Aji", "Amaebi", "Anago", "Aoyagi", "Bincho", "Katsuo", "Ebi", "Hamachi", "Hamachi Toro", "Hirame", "Hokigai", "Hotate", "Ika", "Ikura", "Iwashi", "Kani", "Kanpachi", "Maguro", "Saba", "Sake", "Sake Toro", "Tai", "Tako", "Tamago", "Toro", "Tsubugai", "Umi Masu", "Unagi", "Uni"];
  string[] thirdWords = ["Maki Sushi", "Gunkan Maki", "Temaki", "Nare Sushi", "Nigiri", "Oshi Sushi", "Sasa Sushi", "Kakinoha Sushi", "Temari", "Chirashi Sushi", "Inari Sushi"];
  
  // Random Haiku words
  string[] timeOf = ['summer', 'autumn', 'winter', 'dawn', 'sunset', 'daylight','sunrise', 'noon', 'midnight', 'twilight', 'spring','Christmas', 'Easter', 'morning','afternoon','evening','beach','forest','mountain', 'city', 'neighborhood', 'cliff', 'community', 'farmland', 'field', 'vineyard', 'coast', 'galaxy', 'canyon', 'bay', 'jungle', 'meadow', 'clouds', 'stars', 'paradise','hillside','dunes','desert'];
  string[] adjectives = ['pink','scaly', 'creepy', 'bewildered', 'charming', 'innocent', 'frightened', 'frantic', 'exuberant', 'elated', 'unusual', 'uninterested', 'wicked', 'naughty', 'lonely', 'combative', 'depressed', 'cruel', 'frail', 'jittery', 'lazy', 'proud', 'strange', 'tame', 'wild', 'unsightly', 'fierce', 'busy', 'feathered', 'humped', 'furry', 'fast', 'clucking', 'crazed', 'heavy', 'evil', 'calm', 'energetic', 'smooth', 'small', 'menacing', 'heavy', 'streamline', 'cunning', 'green', 'yellow', 'tall', 'gold', 'grey', 'pink', 'grand', 'springy', 'cute', 'scary', 'sharp', 'hyperactive', 'intelligent', 'nocturnal', 'silly', 'romantic', 'impatient','big','funny','tiny','amazing','slim','kind','generous','happy','jolly','plump','grumpy','special','powerful','weak','mighty', 'fun', 'adorable', 'darling','caring', 'funny', 'merry', 'emotional', 'silly',  'hilarious', 'loathsome',  'giant', 'thundery', 'goofy', 'cute', 'excited', 'happy', 'sarcastic', 'right', 'deadpan', 'fine', 'mad', 'wild', 'hot', 'amazing',  'awesome', 'live', 'exciting', 'bright',  'kind', 'hungry', 'imperfect', 'ornamental', 'delightful',  'terrific', 'neat',  'dark', 'cold', 'friendly', 'pleasant', 'gorgeous', 'cheerful', 'pretty', 'weird', 'big', 'smart', 'enjoyable', 'spruce', 'fancy','academic', 'handsome', 'terrible', 'potable', 'awful', 'perfect', 'light', 'gracious', 'living', 'jolly', 'evil', 'freshwater', 'old', 'gentle',  'little', 'strong', 'fast', 'strange', 'blue', 'excellent', 'pleasing', 'warm', 'educational', 'pale', 'deadly', 'fantastic', 'charming', 'joyful', 'main', 'agreeable',  'mortal', 'heavy', 'content',  'creepy', 'sharp',  'instructional', 'quiet',  'able', 'soft', 'clear',  'empty','textbook','deep', 'dirty', 'ideal', 'attractive', 'afraid',  'clever', 'active', 'odd',  'democratic', 'random',  'hip', 'amusing', 'interesting', 'intense', 'superb',  'secret', 'keen', 'wrong', 'ready', 'shiny', 'playful','major',  'fair',  'liberal',  'glorious',  'long',  'nocturnal','compassionate', 'round', 'acid', 'teary', 'sunny', 'pleasurable', 'comical', 'unreal', 'dry', 'dreamy', 'solid', 'lying', 'huge', 'passionate', 'scary','bold','bouncy','brainy'];
  string[] timeOfAdj = ['breathtaking', 'crisp', 'dazzling', 'ethereal', 'sweeping', 'sparkling', 'rejuvenating', 'idillyc', 'brisk', 'bucolic', 'flourishing', 'glorious', 'lush', 'pristine', 'sun-drenched', 'vast', 'sunny', 'chilly', 'icy', 'magical','cold','freezing','windy','snowy','foggy','dull','biting','rainy','moist','warm','bright','baking','damp','rainy','dark','dry','bushy'];
  string[] singNouns = ['flamingo','aardvark','alligator', 'ant', 'bear', 'bee', 'chicken', 'dog', 'shadow', 'butterfly', 'bird', 'camel', 'cat', 'cheetah', 'chicken', 'chimpanzee', 'cow', 'crocodile', 'deer', 'dog', 'dolphin', 'duck', 'eagle', 'elephant', 'fish', 'fly', 'fox', 'frog', 'giraffe', 'gorilla', 'goat', 'goldfish', "iguana", 'jaguar', 'kangaroo', 'kitten', 'lion', 'lobster', 'monkey', 'octopus', 'owl', 'panda', 'pig', 'puppy', 'pangolin', 'rabbit', 'rat', 'rhinoceros', 'scorpion', 'seal', 'shark', 'sheep', 'snail', 'snake', 'spider', 'squirrel', 'tiger', 'turtle', 'woodpecker', 'wolf', 'zebra', 'sheep', 'alpaca', 'llama', 'whale', 'chocolate', 'girl', 'hammer', 'cube', 'net', 'spanner','bottle','bowl','box','pen','pencil', 'tissue', 'biscuit','house','pebble','leaf','rock','stone','flower','petal','car','lorry','sand castle', 'person', 'pond','spouse','pot','zombie','ghost','vampire','cheese','chalk','salt','pepper','boyfriend','girlfriend', 'man', 'woman', 'father', 'grandfather', 'mother', 'grandmother', 'husband','wife','lake','king','queen','friend','best friend', 'dream', 'pattern', 'devil'];
  string[] otherAdjectives = ['pink','scaly', 'creepy', 'fierce', 'busy', 'feathered', 'humped', 'furry', 'fast', 'clucking', 'crazed', 'heavy', 'evil', 'calm', 'energetic', 'smooth', 'small', 'menacing', 'heavy', 'streamline', 'cunning', 'green', 'yellow', 'tall', 'gold', 'grey', 'pink', 'grand', 'springy', 'cute', 'scary', 'sharp', 'hyperactive', 'intelligent', 'nocturnal', 'silly', 'romantic', 'impatient','big','funny','tiny','amazing','slim','kind','generous','happy','jolly','merry','grumpy','special','powerful','weak','mighty', 'fun', 'adorable', 'darling','caring',  'funny', 'plump', 'emotional', 'silly',  'hilarious', 'loathsome',  'giant', 'thundery', 'goofy', 'cute', 'excited', 'happy', 'sarcastic', 'right', 'deadpan', 'fine', 'mad', 'wild', 'hot', 'amazing',  'awesome', 'live', 'exciting', 'bright',  'kind', 'hungry', 'neat',  'dark', 'cold', 'friendly', 'pleasant', 'sad', 'ornamental', 'delightful',  'terrific', 'gorgeous', 'cheerful', 'pretty', 'weird', 'big', 'smart', 'enjoyable', 'spruce', 'fancy','academic', 'handsome', 'terrible', 'potable', 'awful', 'perfect', 'light', 'gracious', 'living', 'jolly', 'evil', 'freshwater', 'old', 'gentle',  'little', 'strong', 'fast', 'strange', 'blue', 'excellent', 'pleasing', 'warm', 'educational', 'pale', 'deadly', 'fantastic', 'charming', 'joyful', 'main', 'agreeable',  'mortal', 'heavy', 'content',  'creepy', 'sharp',  'instructional', 'quiet',  'able', 'soft', 'clear',  'empty','textbook','deep', 'dirty', 'ideal', 'attractive', 'afraid',  'clever', 'active', 'odd',  'democratic', 'random',  'hip', 'amusing', 'interesting', 'intense', 'superb',  'secret', 'keen', 'wrong', 'ready', 'shiny', 'playful','major',  'fair',  'liberal',  'glorious',  'long',  'nocturnal','compassionate', 'round', 'acid', 'teary', 'sunny', 'pleasurable', 'comical', 'unreal', 'dry', 'dreamy', 'solid', 'lying', 'huge', 'passionate', 'scary','bold','bouncy','brainy'];
  string[] verbs = ['snaps', 'crawls', 'roars', 'breaks', 'relaxes', 'resists', 'sits', 'stretches', 'tiptoes', 'waves', 'waits', 'stings', 'cries', 'hesitate', 'jogs', 'melts', 'occurs', 'plays', 'counts', 'chirps', 'walks', 'calls', 'runs', 'lies', 'looks', 'moos', 'sneers', 'hides', 'barks', 'swims', 'waddles', 'soars', 'paddles', 'burns', 'hunts', 'flies', 'stalks', 'hops', 'skips', 'stands', 'squeals', 'squeaks', 'wallows', 'trots', 'bounces', 'feeds', 'frightens', 'hoots', 'cuddles', 'snorts', 'drools', 'prowls', 'flaps', 'eats', 'slithers', 'sleeps'];
  string[] prepositions = ['after', 'despite', 'into', 'watching', 'above', 'before', 'underneath', 'without', 'upon', 'besides', 'under', 'on', 'behind', 'close to', 'near', 'with', 'beyond', 'along', 'by', 'past', 'around', 'towards', 'on'];

  // Random colors
  string[] colors = ['#E53935', '#D81B60', '#8E24AA', '#5E35B1', '#3949AB', '#1E88E5', '#039BE5', '#00ACC1', '#00897B', '#43A047', '#7CB342', '#C0CA33', '#FDD835', '#FFB300', '#FB8C00', '#F4511E', '#6D4C41', '#757575', '#546E7A','#FFCDD2', '#F8BBD0', '#E1BEE7', '#D1C4E9', '#C5CAE9', '#BBDEFB', '#B3E5FC', '#B2EBF2', '#B2DFDB', '#C8E6C9', '#DCEDC8', '#F0F4C3', '#FFF9C4', '#FFECB3', '#FFE0B2', '#FFCCBC', '#D7CCC8', '#F5F5F5', '#CFD8DC', '#EF9A9A', '#F48FB1', '#CE93D8', '#B39DDB', '#9FA8DA', '#90CAF9', '#81D4FA', '#80DEEA', '#80CBC4', '#A5D6A7', '#8cd790', '#C5E1A5', '#E6EE9C', '#FFF59D', '#FFE082', '#FFCC80', '#FFAB91', '#BCAAA4', '#EEEEEE', '#B0BEC5', '#E57373', '#F06292', '#BA68C8', '#9575CD', '#7986CB', '#64B5F6', '#4FC3F7', '#4DD0E1', '#4DB6AC', '#81C784', '#AED581', '#DCE775', '#FFF176', '#FFD54F', '#FFB74D', '#FF8A65', '#A1887F', '#E0E0E0', '#90A4AE', '#EF5350', '#EC407A', '#AB47BC', '#7E57C2', '#5C6BC0', '#42A5F5', '#29B6F6', '#26C6DA', '#26A69A', '#66BB6A', '#9CCC65', '#D4E157', '#FFEE58', '#FFCA28', '#FFA726', '#FF7043', '#8D6E63', '#BDBDBD', '#78909C', '#F44336', '#E91E63', '#9C27B0', '#673AB7', '#3F51B5', '#2196F3', '#03A9F4', '#00BCD4', '#009688', '#4CAF50', '#8BC34A', '#CDDC39', '#FFEB3B', '#FFC107', '#FF9800', '#FF5722', '#795548', '#9E9E9E', '#607D8B'];

  event NewSushiNFTMinted(address sender, uint256 tokenId, uint256 numberOfNFTs);

  constructor() ERC721 ("sushiNFT", "SUSHI") {
    console.log("sushiNFT contract initialized");
  }

  function pickRandomWord(uint256 tokenId, string memory input, string[] memory listOfWords) public view returns(string memory) {
    uint256 rand = random(string(abi.encodePacked(input, Strings.toString(tokenId))));
    // Squash the # between 0 and the length of the array to avoid going out of bounds.
    rand = rand % listOfWords.length;
    return listOfWords[rand];
  }

  function random(string memory input) internal pure returns(uint256) {
      return uint256(keccak256(abi.encodePacked(input)));
  }

  function howManyNFTs() public view returns(uint256) {
      return _tokenIds.current();
  }

  function capitalizeFirstLetter(string memory str) internal pure returns(string memory) {
    bytes memory bStr = bytes(str);
    if ((uint8(bStr[0]) >= 97) && (uint8(bStr[0]) <= 122)) {
      // We deduct 32 to make it lowercase
      // https://www.rapidtables.com/code/text/ascii-table.html
      bStr[0] = bytes1(uint8(bStr[0]) - 32);
    }
    return string(bStr);
  }

  function chooseCorrectArticle(string memory str) internal pure returns(string memory) {
    bytes memory bStr = bytes(str);
    // https://owl.purdue.edu/owl/general_writing/grammar/using_articles.html
    // An ==> next word starts with a, e, i, o, or silent h
    if ((uint8(bStr[0]) == 97) || (uint8(bStr[0]) == 101) || (uint8(bStr[0]) == 104) || (uint8(bStr[0]) == 105) || (uint8(bStr[0]) == 111)) {
      return "An";
    } else {
      return "A";
    }
  }

  function makeHaikuFirstLine(uint256 id) internal view returns(string memory) {
      string memory randomTimeOfAdjective = pickRandomWord(id, "timeOfAdjective", timeOfAdj);
      randomTimeOfAdjective = capitalizeFirstLetter(randomTimeOfAdjective);
      string memory randomTimeOf = pickRandomWord(id, "time", timeOf);
      string memory firstSentence = string(abi.encodePacked(randomTimeOfAdjective, " ", randomTimeOf));
      return firstSentence;
  }

    function makeHaikuSecondLine(uint256 id) internal view returns(string memory) {
      string memory randomAdjective = pickRandomWord(id, "adjective", adjectives);
      string memory randomOtherAdjective = pickRandomWord(id, "otherAdjective", otherAdjectives);
      string memory randomSingularNoun = pickRandomWord(id, "singularNoun", singNouns);
      string memory randomVerb = pickRandomWord(id, "verb", verbs);
      string memory article = chooseCorrectArticle(randomAdjective);
      string memory secondSentence = string(abi.encodePacked(article, " ", randomAdjective , " ", randomOtherAdjective, " ", randomSingularNoun, " ", randomVerb));
      return secondSentence;
  }

    function makeHaikuThirdLine(uint256 id) internal view returns(string memory) {
      string memory randomPreposition = pickRandomWord(id, 'preposition', prepositions);
      randomPreposition = capitalizeFirstLetter(randomPreposition);
      string memory randomSingularNoun2 = pickRandomWord(id, "otherSingularNoun", singNouns);
      string memory thirdSentence = string(abi.encodePacked(randomPreposition, " ", "the", " ", randomSingularNoun2, unicode"。"));
      return thirdSentence;
  }

  function makeTitle(uint256 id) internal view returns(string memory) {
    string memory first = pickRandomWord(id, "first", firstWords);
    string memory second = pickRandomWord(id, "second", secondWords);
    string memory third = pickRandomWord(id, "third", thirdWords);
    string memory combinedWords = string(abi.encodePacked(first, " ", second, " ", third));
    
    return combinedWords;
  }

  function makeAnEpicNFT() public {
    // require(balanceOf(msg.sender) == 0, 'Each address may only own one sushiNFT');
    require(balanceOf(msg.sender) < 2, 'Each address may only own one sushiNFT');
    require(_tokenIds.current() <= 365, 'Only 365 sushiNFT can be minted!');

     // Get the current tokenId. Starts at 0.
    uint256 newItemId = _tokenIds.current();

    string memory title = makeTitle(newItemId);
    string memory firstLine = makeHaikuFirstLine(newItemId);
    string memory secondLine = makeHaikuSecondLine(newItemId);
    string memory thirdLine = makeHaikuThirdLine(newItemId);

    console.log(firstLine);
    console.log(secondLine);
    console.log(thirdLine);

    string memory randColor = pickRandomWord(newItemId, "randomColor", colors);
    console.log(randColor);

    string memory verseOne = string(abi.encodePacked("<text x='50%' y='40%' class='base' dominant-baseline='middle' text-anchor='middle'>", firstLine, "</text>"));
    string memory verseTwo = string(abi.encodePacked("<text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>", secondLine, "</text>"));
    string memory verseThree = string(abi.encodePacked("<text x='50%' y='60%' class='base' dominant-baseline='middle' text-anchor='middle'>", thirdLine, "</text>"));

    // Concatenate it all together, and then close the <text> and <svg> tags.
    string memory finalSvg = string(abi.encodePacked(baseSvg, randColor,  patternSvg, verseOne, verseTwo, verseThree, "</svg>"));

    console.log(finalSvg);


    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked('{"name": "',title,'", "description": "A highly acclaimed NFT collection from Electric Sheep.", "image": "data:image/svg+xml;base64,',Base64.encode(bytes(finalSvg)),'"}'
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

    emit NewSushiNFTMinted(msg.sender, newItemId, _tokenIds.current());
  }
}
