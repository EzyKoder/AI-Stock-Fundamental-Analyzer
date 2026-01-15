import 'package:ai_stock_analyzer/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  final String phoneNumber;
  final String userId;

  const SignupPage({
    Key? key,
    required this.phoneNumber,
    required this.userId,
  }) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String? _selectedGender;
  String? _selectedState;
  String? _selectedOccupation;
  String? _selectedInvestmentExperience;
  bool _isLoading = false;

  final List<String> _genders = ['Male', 'Female', 'Other', 'Prefer not to say'];
  
  final List<String> _indianStates = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
    'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
    'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
    'Delhi', 'Puducherry', 'Jammu and Kashmir', 'Ladakh'
  ];

  final List<String> _occupations = [
    'Student', 'Salaried', 'Self-Employed', 'Business Owner', 
    'Professional', 'Retired', 'Other'
  ];

  final List<String> _investmentExperiences = [
    'Beginner (0-1 years)', 
    'Intermediate (1-3 years)', 
    'Advanced (3-5 years)', 
    'Expert (5+ years)'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6C63FF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2D3748),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGender == null || _selectedState == null || 
        _selectedOccupation == null || _selectedInvestmentExperience == null) {
      _showError('Please fill all required fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> userData = {
        'phoneNumber': widget.phoneNumber,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'dob': _dobController.text.trim(),
        'gender': _selectedGender!,
        'state': _selectedState!,
        'occupation': _selectedOccupation!,
        'investmentExperience': _selectedInvestmentExperience!,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Create user document in Firestore
      await _firestore.collection('users').doc(widget.userId).set(userData);

      if (mounted) {
        // Navigate to home page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationPage()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Complete Your Profile',
          style: TextStyle(color: Color(0xFF2D3748), fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Message
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF9D8FFF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.waving_hand, color: Colors.white, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            widget.phoneNumber,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Personal Information Section
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 16),
              
              // Name Field
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Email Field
              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'your.email@example.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Date of Birth Field
              _buildTextField(
                controller: _dobController,
                label: 'Date of Birth',
                hint: 'DD/MM/YYYY',
                icon: Icons.calendar_today_outlined,
                readOnly: true,
                onTap: _selectDate,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select your date of birth';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Gender Dropdown
              _buildDropdown(
                label: 'Gender',
                value: _selectedGender,
                items: _genders,
                icon: Icons.person_outline,
                onChanged: (value) => setState(() => _selectedGender = value),
              ),
              const SizedBox(height: 16),
              
              // State Dropdown
              _buildDropdown(
                label: 'State',
                value: _selectedState,
                items: _indianStates,
                icon: Icons.location_on_outlined,
                onChanged: (value) => setState(() => _selectedState = value),
              ),
              const SizedBox(height: 24),
              
              // Investment Profile Section
              const Text(
                'Investment Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 16),
              
              // Occupation Dropdown
              _buildDropdown(
                label: 'Occupation',
                value: _selectedOccupation,
                items: _occupations,
                icon: Icons.work_outline,
                onChanged: (value) => setState(() => _selectedOccupation = value),
              ),
              const SizedBox(height: 16),
              
              // Investment Experience Dropdown
              _buildDropdown(
                label: 'Investment Experience',
                value: _selectedInvestmentExperience,
                items: _investmentExperiences,
                icon: Icons.trending_up,
                onChanged: (value) => setState(() => _selectedInvestmentExperience = value),
              ),
              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Complete Registration',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A5568),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF2D3748),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A5568),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            hint: Text(
              'Select $label',
              style: TextStyle(color: Colors.grey[400]),
            ),
            isExpanded: true,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            validator: (value) {
              if (value == null) {
                return 'Please select $label';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}