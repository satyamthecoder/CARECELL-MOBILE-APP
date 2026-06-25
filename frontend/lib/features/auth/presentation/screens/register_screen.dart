import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/repositories/auth_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = AuthRepository();
  bool _loading = false;
  bool _obscure = true;
  String _role = 'PATIENT';
  bool _isMinor = false;

  final _name     = TextEditingController();
  final _mobile   = TextEditingController();
  final _age      = TextEditingController();
  final _password = TextEditingController();
  final _gName    = TextEditingController();
  final _gMobile  = TextEditingController();
  final _gRel     = TextEditingController();

  String? _gender;
  String? _bloodGroup;
  String? _state;
  bool _guardianConsent = false;

  final _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final _genders = ['MALE', 'FEMALE', 'OTHER'];
  final _states = ['Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka', 'Kerala',
    'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha',
    'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh',
    'Uttarakhand', 'West Bengal', 'Delhi', 'Jammu & Kashmir', 'Ladakh'];

  @override
  void initState() {
    super.initState();
    // Pre-fill role from route param if passed
    _age.addListener(() {
      final a = int.tryParse(_age.text) ?? 0;
      setState(() => _isMinor = a > 0 && a < 18);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isMinor && !_guardianConsent) {
      _showSnack('Guardian consent is required for patients under 18');
      return;
    }
    setState(() => _loading = true);

    final payload = {
      'name': _name.text.trim(),
      'mobileNumber': _mobile.text.trim(),
      'age': int.parse(_age.text.trim()),
      'gender': _gender,
      'bloodGroup': _bloodGroupKey(_bloodGroup!),
      'state': _state,
      'role': _role,
      'password': _password.text,
      if (_isMinor && _role == 'PATIENT') ...{
        'guardianName': _gName.text.trim(),
        'guardianMobile': _gMobile.text.trim(),
        'guardianRelationship': _gRel.text.trim(),
        'guardianConsent': _guardianConsent,
      }
    };

    final result = await _repo.register(payload);
    setState(() => _loading = false);

    if (!mounted) return;
    if (result.isSuccess) {
      context.push('/otp?mobile=${_mobile.text.trim()}&next=/${_role.toLowerCase()}/dashboard');
    } else {
      _showSnack(result.error ?? 'Registration failed');
    }
  }

  String _bloodGroupKey(String display) {
    return display.replaceAll('+', '_POSITIVE').replaceAll('-', '_NEGATIVE');
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account'), leading: BackButton(onPressed: () => context.pop())),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          children: [
            // Role toggle
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingS),
                child: Row(
                  children: ['PATIENT', 'DONOR'].map((r) {
                    final selected = _role == r;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _role = r),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          ),
                          child: Text(r, textAlign: TextAlign.center,
                            style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            _field(_name, 'Full Name', Icons.person_outline, validator: (v) => v!.length < 2 ? 'Enter your full name' : null),
            const SizedBox(height: 12),
            _field(_mobile, 'Mobile Number', Icons.phone_outlined, keyboardType: TextInputType.phone,
              validator: (v) => RegExp(r'^[6-9]\d{9}$').hasMatch(v!) ? null : 'Enter valid 10-digit mobile'),
            const SizedBox(height: 12),
            _field(_age, 'Age', Icons.cake_outlined, keyboardType: TextInputType.number,
              validator: (v) { final a = int.tryParse(v!); return (a == null || a < 1 || a > 120) ? 'Enter valid age' : null; }),
            if (_isMinor && _role == 'DONOR')
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('⚠️ Donors must be 18 or older.', style: TextStyle(color: AppColors.emergency, fontSize: 13)),
              ),
            const SizedBox(height: 12),

            // Gender
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: _dec('Gender', Icons.wc_outlined),
              items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (v) => setState(() => _gender = v),
              validator: (v) => v == null ? 'Select gender' : null,
            ),
            const SizedBox(height: 12),

            // Blood group
            DropdownButtonFormField<String>(
              value: _bloodGroup,
              decoration: _dec('Blood Group', Icons.bloodtype_outlined),
              items: _bloodGroups.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
              onChanged: (v) => setState(() => _bloodGroup = v),
              validator: (v) => v == null ? 'Select blood group' : null,
            ),
            const SizedBox(height: 12),

            // State
            DropdownButtonFormField<String>(
              value: _state,
              decoration: _dec('State', Icons.location_on_outlined),
              items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _state = v),
              validator: (v) => v == null ? 'Select state' : null,
            ),
            const SizedBox(height: 12),

            // Password
            TextFormField(
              controller: _password,
              obscureText: _obscure,
              decoration: _dec('Password', Icons.lock_outline).copyWith(
                suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscure = !_obscure)),
              ),
              validator: (v) => v!.length < 8 ? 'Minimum 8 characters' : null,
            ),

            // Guardian section (minor patients)
            if (_isMinor && _role == 'PATIENT') ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.08),
                  border: Border.all(color: AppColors.warning.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Row(children: [
                    Icon(Icons.family_restroom, color: AppColors.warning),
                    SizedBox(width: 8),
                    Text('Guardian Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ]),
                  const SizedBox(height: 4),
                  const Text('Required for patients under 18 years', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  _field(_gName, 'Guardian Full Name', Icons.person_outline),
                  const SizedBox(height: 12),
                  _field(_gMobile, 'Guardian Mobile', Icons.phone_outlined, keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  _field(_gRel, 'Relationship (e.g. Father)', Icons.people_outline),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: _guardianConsent,
                    onChanged: (v) => setState(() => _guardianConsent = v ?? false),
                    title: const Text('I give consent for this minor to use CareCell', style: TextStyle(fontSize: 13)),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ]),
              ),
            ],

            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: (_loading || (_isMinor && _role == 'DONOR')) ? null : _submit,
              child: _loading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Create Account'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account? '),
                TextButton(onPressed: () => context.go('/login'), child: const Text('Login')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TextFormField _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: _dec(label, icon),
      validator: validator ?? (v) => v!.trim().isEmpty ? 'Required' : null,
    );
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
    labelText: label, prefixIcon: Icon(icon),
  );

  @override
  void dispose() {
    _name.dispose(); _mobile.dispose(); _age.dispose();
    _password.dispose(); _gName.dispose(); _gMobile.dispose(); _gRel.dispose();
    super.dispose();
  }
}
