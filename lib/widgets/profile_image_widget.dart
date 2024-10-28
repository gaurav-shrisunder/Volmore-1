import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:volunterring/Models/response_models/sign_up_response_model.dart';
import 'package:volunterring/Utils/shared_prefs.dart';

class ProfileImageWidget extends StatefulWidget {
  // Callback to handle the base64 string

  const ProfileImageWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfileImageWidget> createState() => _ProfileImageWidgetState();
}

class _ProfileImageWidgetState extends State<ProfileImageWidget> {
  final ImagePicker _picker = ImagePicker();
  User? user;
  File? _imageFile;

  void setVariables() async {
    User? user1 = await getUser();
    print("USer::: ${user1?.userName}");
    setState(() {
      user = user1;
    });
  }

  // Function to pick and convert image to base64
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Compress image to reduce size
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        setState(() {
          _imageFile = File(image.path);
        });
        // widget.onImageSelected(base64String);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to pick image. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    setVariables();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Profile Image Container
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
              ? Center(
                  child: _buildFallbackImage(),
                )
              : ClipOval(
                  child: Builder(
                    builder: (context) {
                      // Show selected image file if available
                      if (_imageFile != null) {
                        return Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildFallbackImage();
                          },
                        );
                      }
                      // Show existing profile picture if available
                      else if (user!.profilePicture != null &&
                          user!.profilePicture!.isNotEmpty) {
                        try {
                          return Image.memory(
                            base64Decode(user!.profilePicture!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildFallbackImage();
                            },
                          );
                        } catch (e) {
                          return _buildFallbackImage();
                        }
                      }
                      // Show fallback image if no picture available
                      return _buildFallbackImage();
                    },
                  ),
                ),
        ),
        // Camera Icon Button
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: InkWell(
              onTap: _pickImage,
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
