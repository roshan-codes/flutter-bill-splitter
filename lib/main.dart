import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dark_glassmorphic_bottom_bar/dark_glassmorphic_bottom_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class Friend {
  final String name;
  final String phone;
  final String? avatarUrl;

  const Friend({
    required this.name,
    required this.phone,
    this.avatarUrl,
  });
}

class Group {
  final String name;
  final List<Friend> members;

  const Group({
    required this.name,
    required this.members,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bill Splitter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7FAF7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF86E829),
          brightness: Brightness.light,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<String> _tabTitles = const [
    'Home',
    'Friends',
    'Activity',
    'Profile',
  ];

  final List<IconData> _tabIcons = const [
    Icons.home_outlined,
    Icons.people_outline_rounded,
    Icons.access_time_rounded,
    Icons.person_outline_rounded,
  ];

  final List<IconData> _tabActiveIcons = const [
    Icons.home_rounded,
    Icons.people_rounded,
    Icons.access_time_filled_rounded,
    Icons.person_rounded,
  ];

  int _friendsSubTab = 0; // 0: Friends, 1: Groups

  final List<Group> _groups = [
    const Group(name: 'Goa Trip', members: []),
    const Group(name: 'Flatmates', members: []),
    const Group(name: 'Office Lunch', members: []),
  ];

  final List<Friend> _friends = [
    const Friend(
      name: 'Alex Johnson',
      phone: '+91 98765 43210',
      avatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=200&q=80',
    ),
    const Friend(
      name: 'David Kalu',
      phone: '+91 91234 56789',
      avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=200&q=80',
    ),
    const Friend(
      name: 'Sophia Martinez',
      phone: '+91 99887 76655',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
    ),
    const Friend(
      name: 'Lucas Silva',
      phone: '+91 98112 23344',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
    ),
  ];

  void _showAddOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose an Option',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF131A15),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF86E829).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF131A15)),
                ),
                title: const Text(
                  'Add New Friend',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                subtitle: const Text(
                  'Add a friend with name and mobile number',
                  style: TextStyle(fontSize: 13, color: Color(0xFF808B82)),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                onTap: () {
                  Navigator.pop(context);
                  _showAddFriendDialog();
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF86E829).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.group_add_rounded, color: Color(0xFF131A15)),
                ),
                title: const Text(
                  'Create New Group',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                subtitle: const Text(
                  'Select members from friends list and name your group',
                  style: TextStyle(fontSize: 13, color: Color(0xFF808B82)),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                onTap: () {
                  Navigator.pop(context);
                  _showCreateGroupDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateGroupDialog() {
    final groupNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final Set<int> selectedMemberIndices = {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF86E829).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.group_add_rounded,
                            color: Color(0xFF131A15),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Create New Group',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF131A15),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Group Name Input Field
                    TextFormField(
                      controller: groupNameController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Group Name',
                        hintText: 'e.g. Goa Trip, Flatmates, Dinner',
                        prefixIcon: const Icon(Icons.groups_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFF86E829), width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter group name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Section Title: Select Members from Friends List
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Members',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF131A15),
                          ),
                        ),
                        Text(
                          '${selectedMemberIndices.length} selected',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF808B82),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Available Friends List to Select From
                    Expanded(
                      child: _friends.isEmpty
                          ? Center(
                              child: Text(
                                'No friends available yet.\nAdd friends first.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            )
                          : ListView.separated(
                              itemCount: _friends.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final friend = _friends[index];
                                final isSelected = selectedMemberIndices.contains(index);
                                final initials = friend.name
                                    .trim()
                                    .split(' ')
                                    .where((e) => e.isNotEmpty)
                                    .map((e) => e[0].toUpperCase())
                                    .take(2)
                                    .join();

                                return InkWell(
                                  onTap: () {
                                    setModalState(() {
                                      if (isSelected) {
                                        selectedMemberIndices.remove(index);
                                      } else {
                                        selectedMemberIndices.add(index);
                                      }
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF86E829).withOpacity(0.08)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF86E829)
                                            : const Color(0xFFE5EDE4),
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: isSelected
                                              ? const Color(0xFF86E829)
                                              : const Color(0xFF86E829).withOpacity(0.2),
                                          child: Text(
                                            initials.isNotEmpty ? initials : '?',
                                            style: TextStyle(
                                              color: isSelected
                                                  ? const Color(0xFF10210A)
                                                  : const Color(0xFF284821),
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                friend.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                  color: Color(0xFF131A15),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                friend.phone,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF808B82),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          isSelected
                                              ? Icons.check_circle_rounded
                                              : Icons.circle_outlined,
                                          color: isSelected
                                              ? const Color(0xFF86E829)
                                              : const Color(0xFFC4CDC3),
                                          size: 24,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF86E829),
                              foregroundColor: const Color(0xFF10210A),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              if (formKey.currentState?.validate() ?? false) {
                                if (selectedMemberIndices.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please select at least 1 member for the group'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }

                                final gName = groupNameController.text.trim();
                                final selectedFriends = selectedMemberIndices
                                    .map((i) => _friends[i])
                                    .toList();

                                setState(() {
                                  _groups.add(
                                    Group(name: gName, members: selectedFriends),
                                  );
                                  _friendsSubTab = 1;
                                });

                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Group "$gName" created with ${selectedFriends.length} members!',
                                    ),
                                    backgroundColor: const Color(0xFF111713),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'Create Group',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddFriendDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Row(
          children: [
            Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF86E829)),
            SizedBox(width: 10),
            Text(
              'Add Friend',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF131A15),
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Friend Name',
                  hintText: 'Enter name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF86E829), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  hintText: 'Enter mobile no',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF86E829), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter mobile number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF86E829),
              foregroundColor: const Color(0xFF10210A),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                setState(() {
                  _friends.add(
                    Friend(
                      name: nameController.text.trim(),
                      phone: phoneController.text.trim(),
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openAddExpenseScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(
          friends: _friends,
          groups: _groups,
        ),
      ),
    );
  }

  Widget _buildFriendsTab() {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _friendsSubTab = 0),
                      child: Text(
                        'Friends',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: _friendsSubTab == 0
                              ? const Color(0xFF131A15)
                              : Colors.grey.shade400,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => setState(() => _friendsSubTab = 1),
                      child: Text(
                        'Groups',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: _friendsSubTab == 1
                              ? const Color(0xFF131A15)
                              : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  tooltip: 'Add',
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF86E829),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF86E829).withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Color(0xFF10210A),
                      size: 22,
                    ),
                  ),
                  onPressed: _showAddOptionsMenu,
                ),
              ],
            ),
          ),
          Expanded(
            child: _friendsSubTab == 0
                ? (_friends.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline_rounded,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No friends yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tap + to add your first friend',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                        itemCount: _friends.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final friend = _friends[index];
                          final initials = friend.name
                              .trim()
                              .split(' ')
                              .where((e) => e.isNotEmpty)
                              .map((e) => e[0].toUpperCase())
                              .take(2)
                              .join();

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFE5EDE4),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: const Color(0xFF86E829).withOpacity(0.2),
                                  child: Text(
                                    initials.isNotEmpty ? initials : '?',
                                    style: const TextStyle(
                                      color: Color(0xFF284821),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        friend.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF131A15),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.phone_outlined,
                                            size: 14,
                                            color: Color(0xFF808B82),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            friend.phone,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF808B82),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _friends.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ))
                : (_groups.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.groups_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No groups created yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tap + and choose "Create New Group"',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                        itemCount: _groups.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final group = _groups[index];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFE5EDE4),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF86E829).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.groups_rounded,
                                    color: Color(0xFF284821),
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        group.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF131A15),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${group.members.length} members',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF808B82),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _groups.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      )),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultTab(int index) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFF86E829),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _tabActiveIcons[index],
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _tabTitles[index],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF131A15),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFriendsTab = _currentIndex == 1;

    return Scaffold(
      extendBody: true,
      appBar: isFriendsTab
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(
                _tabTitles[_currentIndex],
                style: const TextStyle(
                  color: Color(0xFF131A15),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
      body: isFriendsTab ? _buildFriendsTab() : _buildDefaultTab(_currentIndex),
      bottomNavigationBar: DarkGlassmorphicBottomBar(
        selectedIndex: _currentIndex,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        centerAction: DarkGlassActionItem(
          icon: Icons.add,
          onTap: _openAddExpenseScreen,
        ),
        items: List.generate(
          _tabTitles.length,
          (i) => DarkGlassNavItem(
            icon: _tabIcons[i],
            activeIcon: _tabActiveIcons[i],
            label: _tabTitles[i],
          ),
        ),
      ),
    );
  }
}

/// Full-screen view for Adding an Expense with Available Groups, rectangular container, and Friends list.
class AddExpenseScreen extends StatefulWidget {
  final List<Friend> friends;
  final List<Group> groups;

  const AddExpenseScreen({
    super.key,
    required this.friends,
    required this.groups,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _groupNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final Set<int> _selectedFriendIndices = {};
  int? _selectedGroupIndex;

  @override
  void initState() {
    super.initState();
    // Pre-select initial friends so the container shows selected contacts on open
    for (int i = 0; i < widget.friends.length && i < 4; i++) {
      _selectedFriendIndices.add(i);
    }
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF131A15),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add & Split Expense',
          style: TextStyle(
            color: Color(0xFF131A15),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Available Groups Section (Horizontally Scrollable)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Available Groups',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF131A15),
                      ),
                    ),
                    Text(
                      '${widget.groups.length} groups',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF808B82),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 58,
                  child: widget.groups.isEmpty
                      ? Center(
                          child: Text(
                            'No groups created yet',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                          ),
                        )
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.groups.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final group = widget.groups[index];
                            final isSelected = _selectedGroupIndex == index ||
                                _groupNameController.text.trim() == group.name;

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedGroupIndex = index;
                                  _groupNameController.text = group.name;

                                  // Pre-select group members if any
                                  if (group.members.isNotEmpty) {
                                    _selectedFriendIndices.clear();
                                    for (final member in group.members) {
                                      final found = widget.friends.indexWhere(
                                        (f) => f.name == member.name || f.phone == member.phone,
                                      );
                                      if (found != -1) {
                                        _selectedFriendIndices.add(found);
                                      }
                                    }
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF111713) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF86E829) : const Color(0xFFE5EDE4),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF86E829)
                                            : const Color(0xFF86E829).withOpacity(0.18),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.groups_rounded,
                                        size: 16,
                                        color: isSelected ? const Color(0xFF10210A) : const Color(0xFF284821),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          group.name,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected ? Colors.white : const Color(0xFF131A15),
                                          ),
                                        ),
                                        Text(
                                          '${group.members.length} members',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isSelected ? Colors.white60 : const Color(0xFF808B82),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 20),

                // Group Name Field
                const Text(
                  'Group Name',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF131A15),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _groupNameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Goa Trip, Dinner, Flat Rent',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.groups_outlined, color: Color(0xFF808B82)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE5EDE4)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE5EDE4)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF86E829), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter group name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Rectangular Container for Selected Contacts (like screenshot)
                Container(
                  width: double.infinity,
                  height: 110,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFDCE5DC),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _selectedFriendIndices.isEmpty
                      ? Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.touch_app_outlined,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Select friends below to add them here',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedFriendIndices.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 18),
                          itemBuilder: (context, idx) {
                            final friendIndex = _selectedFriendIndices.elementAt(idx);
                            final friend = widget.friends[friendIndex];
                            final initials = friend.name
                                .trim()
                                .split(' ')
                                .where((e) => e.isNotEmpty)
                                .map((e) => e[0].toUpperCase())
                                .take(2)
                                .join();

                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Contact Avatar Squircle
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF86E829).withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFFE5EDE4),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: friend.avatarUrl != null
                                        ? Image.network(
                                            friend.avatarUrl!,
                                            width: 72,
                                            height: 72,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Center(
                                              child: Text(
                                                initials,
                                                style: const TextStyle(
                                                  color: Color(0xFF284821),
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: Text(
                                              initials,
                                              style: const TextStyle(
                                                color: Color(0xFF284821),
                                                fontWeight: FontWeight.w800,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),

                                // Top-Right White Circle Badge with 'x' icon
                                Positioned(
                                  top: -5,
                                  right: -5,
                                  child: GestureDetector(
                                    key: ValueKey('remove_selected_${friend.name}'),
                                    onTap: () {
                                      setState(() {
                                        _selectedFriendIndices.remove(friendIndex);
                                      });
                                    },
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.25),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: Color(0xFF131A15),
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
                const SizedBox(height: 28),

                // Friends Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Friends',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF131A15),
                      ),
                    ),
                    Text(
                      '${widget.friends.length} available',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF808B82),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Items from Friend List
                if (widget.friends.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE5EDE4)),
                    ),
                    child: const Center(
                      child: Text(
                        'No friends in your list.\nAdd friends in the Friends tab.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF808B82), fontSize: 14),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.friends.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final friend = widget.friends[index];
                      final isSelected = _selectedFriendIndices.contains(index);
                      final initials = friend.name
                          .trim()
                          .split(' ')
                          .where((e) => e.isNotEmpty)
                          .map((e) => e[0].toUpperCase())
                          .take(2)
                          .join();

                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedFriendIndices.remove(index);
                            } else {
                              _selectedFriendIndices.add(index);
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF86E829) : const Color(0xFFE5EDE4),
                              width: isSelected ? 1.5 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: isSelected
                                    ? const Color(0xFF86E829)
                                    : const Color(0xFF86E829).withOpacity(0.18),
                                child: Text(
                                  initials.isNotEmpty ? initials : '?',
                                  style: TextStyle(
                                    color: isSelected ? const Color(0xFF10210A) : const Color(0xFF284821),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      friend.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF131A15),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      friend.phone,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF808B82),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                                color: isSelected ? const Color(0xFF86E829) : const Color(0xFFC4CDC3),
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 32),

                // Confirm Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF86E829),
                      foregroundColor: const Color(0xFF10210A),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        final gName = _groupNameController.text.trim();
                        final selectedCount = _selectedFriendIndices.length;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Group "$gName" created with $selectedCount friends selected!',
                            ),
                            backgroundColor: const Color(0xFF111713),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Confirm & Split',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
