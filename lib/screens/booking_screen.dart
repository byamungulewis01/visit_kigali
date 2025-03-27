import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../models/tourist.dart';
import '../services/api_service.dart';
import '../widgets/custom_text_field.dart';

// Define the BookingStep enum outside the class
enum BookingStep { search, register, bookingDetails }

class BookingScreen extends StatefulWidget {
  final int placeId;

  const BookingScreen({Key? key, required this.placeId}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _apiService = ApiService();
  
  // Step tracking
  BookingStep _currentStep = BookingStep.search;
  
  // Search form
  final _searchFormKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  
  // Registration form
  final _registerFormKey = GlobalKey<FormState>();
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalityController = TextEditingController();
  DateTime? _dateOfBirth;
  
  // Booking form
  final _bookingFormKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  DateTime? _bookingDate;
  
  // Selected tourist data
  Tourist? _selectedTourist;
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _touristNotFound = false;

  Future<void> _searchTourist() async {
    if (!_searchFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _touristNotFound = false;
    });

    try {
      final tourist = await _apiService.searchTourist(_searchController.text);
      setState(() {
        _selectedTourist = tourist;
        _currentStep = BookingStep.bookingDetails;
      });
    } catch (e) {
      if (e.toString().contains('404')) {
        // Tourist not found, but we stay on search screen and show options
        setState(() {
          _touristNotFound = true;
          
          // Prefill email or phone based on search term for later
          final searchTerm = _searchController.text;
          if (searchTerm.contains('@')) {
            _emailController.text = searchTerm;
          } else if (searchTerm.contains(RegExp(r'^\d+$'))) {
            // Only prefill if it's all digits
            _phoneController.text = searchTerm;
          }
        });
      } else {
        setState(() {
          _errorMessage = 'Error: ${e.toString()}';
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _continueAsNewTourist() {
    setState(() {
      _currentStep = BookingStep.register;
    });
  }

  Future<void> _registerTourist() async {
    if (!_registerFormKey.currentState!.validate() || _dateOfBirth == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tourist = Tourist(
        fname: _fnameController.text,
        lname: _lnameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        dateOfBirth: _dateOfBirth!,
        nationality: _nationalityController.text,
      );

      final registeredTourist = await _apiService.registerTourist(tourist);
      
      setState(() {
        _selectedTourist = registeredTourist;
        _currentStep = BookingStep.bookingDetails;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Registration error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (!_bookingFormKey.currentState!.validate() || _bookingDate == null || _selectedTourist == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final booking = Booking(
        touristId: _selectedTourist!.id!,
        bookingDate: _bookingDate!,
        comment: _commentController.text,
        placeId: widget.placeId,
      );

      await _apiService.createBooking(booking);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking submitted successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Booking error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // Default to 18 years ago
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)), // 100 years ago
      lastDate: DateTime.now().subtract(const Duration(days: 1)), // Yesterday
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _selectBookingDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _bookingDate = picked;
      });
    }
  }

  Widget _buildSearchStep() {
    return Form(
      key: _searchFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Enter email or phone to search for existing tourist:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _searchController,
            label: 'Email or Phone',
            validator: (value) {
              if (value == null || value.length < 3) {
                return 'Please enter at least 3 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _searchTourist,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Search'),
          ),
          if (_touristNotFound) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tourist not found',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We couldn\'t find a tourist with that information. Would you like to:',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _touristNotFound = false;
                            _searchController.clear();
                          });
                        },
                        child: const Text('Try Again'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _continueAsNewTourist,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: const Text('Continue as New Tourist'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          TextButton(
            onPressed: _continueAsNewTourist,
            child: const Text('Register as New Tourist'),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterStep() {
    return Form(
      key: _registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Register New Tourist',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _fnameController,
            label: 'First Name',
            validator: (value) {
              if (value == null || value.length < 2) {
                return 'First name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _lnameController,
            label: 'Last Name',
            validator: (value) {
              if (value == null || value.length < 2) {
                return 'Last name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || !value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Phone field with numeric-only input
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              hintText: 'Numbers only',
              prefixIcon: const Icon(Icons.phone),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Only allows digits
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Phone number is required';
              }
              
              if (value.length < 10) {
                return 'Phone number must have at least 10 digits';
              }
              
              return null;
            },
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _selectDateOfBirth,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                errorText: _dateOfBirth == null ? 'Required' : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _dateOfBirth == null
                        ? 'Select Date of Birth'
                        : DateFormat('MMM dd, yyyy').format(_dateOfBirth!),
                  ),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _nationalityController,
            label: 'Nationality',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nationality is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentStep = BookingStep.search;
                    _touristNotFound = false;
                  });
                },
                child: const Text('Back'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading ? null : _registerTourist,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Register & Continue'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingStep() {
    return Form(
      key: _bookingFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tourist: ${_selectedTourist?.fname} ${_selectedTourist?.lname}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Email: ${_selectedTourist?.email}'),
                  Text('Phone: ${_selectedTourist?.phone}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _selectBookingDate,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Booking Date',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                errorText: _bookingDate == null ? 'Required' : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _bookingDate == null
                        ? 'Select Date'
                        : DateFormat('MMM dd, yyyy').format(_bookingDate!),
                  ),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _commentController,
            label: 'Comment (Optional)',
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentStep = BookingStep.search;
                    _touristNotFound = false;
                  });
                },
                child: const Text('Start Over'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitBooking,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Submit Booking'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Visit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade900),
                ),
              ),
            _buildStepIndicator(),
            const SizedBox(height: 24),
            if (_currentStep == BookingStep.search)
              _buildSearchStep()
            else if (_currentStep == BookingStep.register)
              _buildRegisterStep()
            else
              _buildBookingStep(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepBubble(
          'Search',
          _currentStep == BookingStep.search,
          _currentStep.index >= BookingStep.search.index,
        ),
        _buildStepLine(_currentStep.index > BookingStep.search.index),
        _buildStepBubble(
          'Register',
          _currentStep == BookingStep.register,
          _currentStep.index >= BookingStep.register.index,
        ),
        _buildStepLine(_currentStep.index > BookingStep.register.index),
        _buildStepBubble(
          'Book',
          _currentStep == BookingStep.bookingDetails,
          _currentStep.index >= BookingStep.bookingDetails.index,
        ),
      ],
    );
  }

  Widget _buildStepBubble(String label, bool isActive, bool isCompleted) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isActive ? Theme.of(context).primaryColor : 
                    isCompleted ? Colors.green : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : Text(
                      label.substring(0, 1),
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Theme.of(context).primaryColor : Colors.black54,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(bool isCompleted) {
    return Container(
      width: 40,
      height: 2,
      color: isCompleted ? Colors.green : Colors.grey.shade300,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fnameController.dispose();
    _lnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nationalityController.dispose();
    _commentController.dispose();
    super.dispose();
  }
}