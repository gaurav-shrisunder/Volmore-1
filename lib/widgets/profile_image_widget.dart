import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:share_plus/share_plus.dart';
import 'package:volunterring/Models/response_models/sign_up_response_model.dart';
import 'package:volunterring/Utils/shared_prefs.dart';
import 'package:volunterring/api_constants.dart';

class ProfileImageWidget extends StatefulWidget {
  const ProfileImageWidget({Key? key}) : super(key: key);

  @override
  State<ProfileImageWidget> createState() => _ProfileImageWidgetState();
}

class _ProfileImageWidgetState extends State<ProfileImageWidget> {
  final ImagePicker _picker = ImagePicker();
  User? user;
  File? _imageFile;
  bool _isPickerActive = false;

  void setVariables() async {
    User? user1 = await getUser();
    if (mounted) {
      setState(() {
        user = user1;
      });
    }
  }

  // Function to pick and convert image to base64
  Future<void> _pickImage() async {
    if (_isPickerActive) {
      debugPrint('Image picker is already active');
      return;
    }

    try {
      setState(() {
        _isPickerActive = true;
      });

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (!mounted) return;

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });

        await _uploadImage(image);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to pick image. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickerActive = false;
        });
      }
    }
  }

  Future<void> _uploadImage(XFile image) async {
    try {
      final userId = await getUserId();
      debugPrint('userId: $userId'); // Log userId for debugging

      // Construct and log the full URL
      final url = Uri.parse('https://dev.volmore.maizelab-cloud.com/api/v1/users/$userId/updateProfilePicture');
      debugPrint('Request URL: ${url.toString()}');

      final request = http.MultipartRequest('PUT', url);

      // Add userId to request field
      // request.fields['x-userid'] = userId;

      // Add file to request
      final file = await http.MultipartFile.fromPath(
        'profilePic',
        image.path,
        contentType: MediaType('image', 'jpg'), // Try jpeg instead of png
      );
      request.files.add(file);

      // Add headers
      final token = await getBearerToken();
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': '*/*',
        'Content-Type': 'multipart/form-data', // Add content type header
        'x-userid': userId
      });

      // Log request details for debugging
      debugPrint('Request headers: ${request.headers}');
      debugPrint('Request fields: ${request.fields}');
      debugPrint('Request files: ${request.files.map((f) => f.filename).toList()}');

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Log response details
      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      debugPrint('Response headers: ${response.headers}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Profile Updated Successfully",
          backgroundColor: Colors.green,
        );
        // Refresh user data
      } else {
        String errorMessage = 'Failed to update profile';

        // Try to parse error message from response
        try {
          if (response.body.isNotEmpty) {
            final jsonResponse = jsonDecode(response.body);
            errorMessage = jsonResponse['message'] ?? errorMessage;
          }
        } catch (e) {
          debugPrint('Error parsing response body: $e');
        }

        Fluttertoast.showToast(
          msg: errorMessage,
          backgroundColor: Colors.red,
        );

        // Log detailed error information
        debugPrint('Update profile failed with status: ${response.statusCode}');
        debugPrint('Error response body: ${response.body}');
      }
    } catch (e, stackTrace) {
      // Log detailed error information
      debugPrint('Error uploading image: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        Fluttertoast.showToast(
          msg: "Network error occurred",
          backgroundColor: Colors.red,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setVariables();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          child: user == null
              ? Center(child: _buildFallbackImage())
              : ClipOval(
                  child: Builder(
                    builder: (context) {
                      if (_imageFile != null) {
                        return Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildFallbackImage(),
                        );
                      } else if (user!.profilePicture != null &&
                          user!.profilePicture!.isNotEmpty) {
                        try {
                          return Image.memory(
                            base64Decode(user!.profilePicture!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildFallbackImage(),
                          );
                        } catch (e) {
                          return _buildFallbackImage();
                        }
                      }
                      return _buildFallbackImage();
                    },
                  ),
                ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _isPickerActive
                  ? Colors.grey
                  : Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: InkWell(
              onTap: _isPickerActive ? null : _pickImage,
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackImage() {
    return Image.network(
      'https://ui-avatars.com/api/?name=${user?.userName ?? "User"}',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.person,
          size: 60,
          color: Colors.grey,
        );
      },
    );
  }
}
