/// Utility for gender-aware, deterministic memo avatar assignment.
/// Matches male and female memo avatars from the 35 illustrated Memo kit.
class AvatarResolver {
  // Female memo avatar indices (1-based, matching assets/avatars/memo_X.png)
  static const List<int> femaleMemoIndices = [
    1, // blonde sunglasses
    2, // red bucket hat, dreads
    4, // double buns, earrings
    5, // elderly lady
    6, // cream hijab
    8, // blonde, pink cat-eye sunglasses
    9, // beret, makeup
    10, // mask, hoop earrings
    11, // blue hair, yellow shades
    14, // pink-tipped hair, earring
    16, // black hair, glasses
    17, // blonde curly, yellow beanie
    18, // bear hat, earrings
    19, // green beanie, glasses, thumbs up
    21, // pink top hat
    27, // grey fedora, bob cut
    28, // purple hijab, glasses
    29, // braids, freckles
    30, // black cap, brown hair
    33, // double buns, wink
    35, // elderly lady, glasses
  ];

  // Male memo avatar indices (1-based, matching assets/avatars/memo_X.png)
  static const List<int> maleMemoIndices = [
    3, // mustache, scout hat
    7, // yellow durag, beard, goatee
    12, // blue fedora, mustache
    13, // short black hair boy
    15, // orange turban, beard
    20, // buzzcut, ear hoops
    22, // pompadour, green shades
    23, // red beanie, glasses, wink
    24, // man bun, glasses, mask
    25, // dreadlocks, orange shades, beard
    26, // curly hair, round sunglasses
    31, // brown bowl cut boy
    32, // spiked hair, red glasses, goatee
    34, // sombrero, eyepatch
  ];

  // Common Indian and global female names
  static const Set<String> _explicitFemaleNames = {
    'kaavya', 'kavya', 'gunjan', 'sharda', 'priya', 'pooja', 'puja', 'ananya',
    'sneha', 'neha', 'riya', 'rhea', 'aditi', 'divya', 'deepika', 'sunita',
    'anita', 'rekha', 'aarti', 'arti', 'swati', 'shreya', 'tanvi', 'mansi',
    'rashi', 'sakshi', 'nisha', 'simran', 'muskan', 'bhavna', 'rashmi',
    'anjali', 'megha', 'shilpa', 'shruti', 'sonal', 'payal', 'komal', 'kajal',
    'nikita', 'prerna', 'pallavi', 'poonam', 'preeti', 'priti', 'neetu', 'nitu',
    'geeta', 'seema', 'radha', 'meena', 'rani', 'jyoti', 'mona', 'sonia',
    'sonya', 'madhu', 'mamta', 'vandana', 'sarita', 'sapna', 'chhaya', 'alka',
    'bina', 'dimple', 'hema', 'jaya', 'kiran', 'leela', 'manju', 'nandini',
    'padma', 'parul', 'rachna', 'renu', 'roshni', 'rupali', 'sangita', 'sangeeta',
    'santosh', 'saroj', 'shashi', 'sheela', 'shobha', 'sita', 'sudha', 'suman',
    'sushma', 'tanya', 'urvashi', 'ushma', 'vidya', 'vinita', 'yashoda',
    'mary', 'sarah', 'emily', 'jessica', 'emma', 'olivia', 'sophia', 'isabella',
    'mia', 'charlotte', 'amelia', 'harper', 'evelyn', 'abigail', 'elizabeth',
    'anna', 'chloe', 'ella', 'grace', 'zoe', 'natalie', 'lily', 'hannah',
  };

  // Common Indian and global male names
  static const Set<String> _explicitMaleNames = {
    'roshan', 'rahul', 'amit', 'rohan', 'rohit', 'raj', 'rajesh', 'suresh',
    'ajay', 'vijay', 'aditya', 'aniket', 'sachin', 'vivek', 'gaurav', 'kunal',
    'varun', 'karan', 'vikram', 'akash', 'aakash', 'abhishek', 'deepak',
    'manish', 'pankaj', 'sandeep', 'pradeep', 'sumit', 'mohit', 'nitin',
    'ashish', 'mayank', 'harsh', 'ayush', 'aman', 'arjun', 'vikas', 'anil',
    'sunil', 'mukesh', 'dinesh', 'sanjay', 'ramesh', 'naresh', 'mahesh',
    'umesh', 'ganesh', 'vinod', 'pramod', 'subhash', 'satish', 'jagdish',
    'harish', 'girish', 'dev', 'ravi', 'kailash', 'prakash', 'om', 'mohan',
    'sohan', 'krishna', 'shiva', 'vishnu', 'brahma', 'govind', 'gopal',
    'shyam', 'alok', 'atul', 'chetan', 'dhruv', 'hemant', 'ishaan', 'jaideep',
    'john', 'david', 'michael', 'james', 'robert', 'william', 'joseph',
    'thomas', 'charles', 'christopher', 'daniel', 'matthew', 'anthony', 'donald',
    'mark', 'paul', 'steven', 'andrew', 'kenneth', 'joshua', 'kevin', 'brian',
  };

  /// Determines if a given name is likely female based on dictionaries and linguistic suffixes.
  static bool isFemaleName(String rawName) {
    final clean = rawName
        .replaceAll(RegExp(r'\s*\(you\)\s*$', caseSensitive: false), '')
        .toLowerCase()
        .trim();
    if (clean.isEmpty) return false;

    final firstName = clean.split(' ').first;

    if (_explicitFemaleNames.contains(firstName)) return true;
    if (_explicitMaleNames.contains(firstName)) return false;

    // Feminine phonetic suffixes common across Indian and European languages:
    // e.g. -a, -i, -ee, -ya, -ti, -ka, -na, -ta, -sha, -ri, -shi
    if (firstName.endsWith('a') ||
        firstName.endsWith('i') ||
        firstName.endsWith('ee') ||
        firstName.endsWith('ya') ||
        firstName.endsWith('ti') ||
        firstName.endsWith('ka') ||
        firstName.endsWith('na') ||
        firstName.endsWith('ta') ||
        firstName.endsWith('sha') ||
        firstName.endsWith('ri') ||
        firstName.endsWith('shi')) {
      // Exclude common male names ending in -a or -i
      const maleExceptions = {'aditya', 'krishna', 'shiva', 'rabi', 'ravi', 'ali'};
      if (!maleExceptions.contains(firstName)) {
        return true;
      }
    }

    return false;
  }

  /// Returns a deterministic memo avatar asset path ('assets/avatars/memo_X.png')
  /// matched to the gender of [name].
  static String getDefaultAvatarForName(String name) {
    final index = getDefaultAvatarIndexForName(name);
    return 'assets/avatars/memo_$index.png';
  }

  /// Returns a deterministic 1-based memo avatar index (1-35) matched to the gender of [name].
  static int getDefaultAvatarIndexForName(String name) {
    final clean = name
        .replaceAll(RegExp(r'\s*\(you\)\s*$', caseSensitive: false), '')
        .toLowerCase()
        .trim();
    final isFemale = isFemaleName(clean);

    final pool = isFemale ? femaleMemoIndices : maleMemoIndices;
    final hash = clean.hashCode.abs();
    return pool[hash % pool.length];
  }
}
