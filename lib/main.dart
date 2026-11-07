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
        builder: (context) => AddExpenseScreen(friends: _friends),
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
                const Text(
                  'Friends',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF131A15),
                  ),
                ),
                IconButton(
                  tooltip: 'Add Friend',
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
                  onPressed: _showAddFriendDialog,
                ),
              ],
            ),
          ),
          Expanded(
            child: _friends.isEmpty
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
                  ),
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

/// Full-screen view for Adding an Expense with a rectangular container and Friends list.
class AddExpenseScreen extends StatefulWidget {
  final List<Friend> friends;

  const AddExpenseScreen({
    super.key,
    required this.friends,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _groupNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final Set<int> _selectedFriendIndices = {};

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
