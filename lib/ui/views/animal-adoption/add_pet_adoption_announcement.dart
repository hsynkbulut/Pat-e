// ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously, avoid_print
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pat_e/common/constants/app_constant.dart';
import 'package:pat_e/core/models/animal_adoption_model.dart';
import 'package:pat_e/core/services/animal_adoption_service.dart';
import 'package:pat_e/core/utils/themes/color.dart';
import 'package:pat_e/ui/components/customappbar.dart';
import 'package:pat_e/ui/components/custom_text_input.dart';

class AddPetAdoptionAnnouncement extends StatefulWidget {
  @override
  _AddPetAdoptionAnnouncementState createState() =>
      _AddPetAdoptionAnnouncementState();
}

class _AddPetAdoptionAnnouncementState
    extends State<AddPetAdoptionAnnouncement> {
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _adoptionConditionsController =
      TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  String _gender = '';
  bool _isAdopted = false;
  List<File> _selectedPhotos = [];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickPhotos() async {
    List<XFile>? pickedImages = await _picker.pickMultiImage(imageQuality: 70);
    if (pickedImages != null) {
      List<File> selectedPhotos =
          pickedImages.map((e) => File(e.path)).toList();
      setState(() {
        _selectedPhotos = selectedPhotos;
      });
    }
  }

  Future<void> _createAnimalAdoption() async {
    if (_selectedPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen en az bir fotoğraf seçiniz')),
      );
      return;
    }

    String newAnimalID = DateTime.now().millisecondsSinceEpoch.toString();

    AnimalAdoption animal = AnimalAdoption(
      animalID: newAnimalID,
      type: _typeController.text,
      name: _nameController.text,
      age: _ageController.text,
      gender: _gender,
      photos: [], // Boş liste olarak başlatın
      adoptionConditions: _adoptionConditionsController.text,
      contactNumber: _contactNumberController.text,
      isAdopted: _isAdopted,
    );

    AnimalAdoptionService service = AnimalAdoptionService();

    try {
      await service.createAnimalAdoption(animal,
          _selectedPhotos); // Güncellenmiş nesneyi Firestore veritabanına kaydedin
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hayvan ilanı oluşturma başarılı')),
      );
      _resetForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hayvan ilanı oluşturma başarısız')),
      );
      print(e.toString());
    }
  }

  void _resetForm() {
    _typeController.clear();
    _nameController.clear();
    _ageController.clear();
    _adoptionConditionsController.clear();
    _contactNumberController.clear();
    setState(() {
      _selectedPhotos = [];
      _gender = '';
      _isAdopted = false;
    });
  }

  @override
  void dispose() {
    _typeController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _adoptionConditionsController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        showBackButton: true,
        pageTitle: AppConstant.addPetAdoptionAnnouncementTitle,
      ),
      body: Container(
        color: bgColor,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickPhotos,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _selectedPhotos.isNotEmpty
                      ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedPhotos.length,
                          itemBuilder: (context, index) {
                            return Image.file(
                              _selectedPhotos[index],
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : const Icon(
                          Icons.camera_alt,
                          color: primaryColor,
                          size: 40,
                        ),
                ),
              ),
              CustomTextInput(
                textEditController: _typeController,
                hintTextString: 'Hayvanın türünü girin',
                inputType: InputType.Default,
                enableBorder: true,
                themeColor: primaryColor,
                cornerRadius: 10.0,
                maxLength: 24,
                prefixIcon: const Icon(Icons.pets, color: primaryColor),
                textColor: Colors.black,
                errorMessage: 'Hayvan türü boş bırakılamaz',
                labelText: 'Hayvanın Türü',
              ),
              CustomTextInput(
                textEditController: _nameController,
                hintTextString: 'Hayvanın Adını girin',
                inputType: InputType.Default,
                enableBorder: true,
                cornerRadius: 10.0,
                maxLength: 24,
                errorMessage: 'Hayvan adı boş bırakılamaz',
                labelText: 'Hayvanın Adı',
                prefixIcon: const Icon(Icons.near_me, color: primaryColor),
                textColor: mainAuxiliaryColor,
                themeColor: primaryColor,
              ),
              CustomTextInput(
                textEditController: _ageController,
                hintTextString: 'Hayvanın yaşını girin',
                inputType: InputType.Default,
                enableBorder: true,
                cornerRadius: 10.0,
                maxLength: 16,
                prefixIcon: const Icon(Icons.date_range, color: primaryColor),
                errorMessage: 'Hayvan yaşı boş bırakılamaz',
                labelText: 'Hayvanın Yaşı',
                textColor: mainAuxiliaryColor,
                themeColor: primaryColor,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio<String>(
                    value: 'Dişi',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                  ),
                  const Text('Dişi'),
                  Radio<String>(
                    value: 'Erkek',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                  ),
                  const Text('Erkek'),
                ],
              ),
              CustomTextInput(
                textEditController: _contactNumberController,
                hintTextString: 'İletişim numaranızı girin',
                inputType: InputType.Number,
                enableBorder: true,
                cornerRadius: 10.0,
                maxLength: 11,
                prefixIcon: const Icon(Icons.phone, color: primaryColor),
                labelText: 'İletişim Numarası',
                textColor: mainAuxiliaryColor,
                themeColor: primaryColor,
                errorMessage: 'Telefon numarası boş bırakılamaz',
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                child: TextField(
                  controller: _adoptionConditionsController,
                  maxLines: 5,
                  maxLength: 400,
                  cursorColor: primaryColor,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    labelText: "Sahiplendirme Koşulları",
                    labelStyle: TextStyle(color: primaryColor),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        style: BorderStyle.solid,
                        color: Colors.red,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 2, style: BorderStyle.solid, color: gold),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(
                          width: 2,
                          style: BorderStyle.solid,
                          color: primaryColor),
                    ),
                    hintText: 'Açıklama girin',
                    prefixIcon: Icon(
                      Icons.description,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sahibini Bekliyor'),
                  Switch(
                    value: _isAdopted,
                    onChanged: (value) {
                      setState(() {
                        _isAdopted = value;
                      });
                    },
                    activeTrackColor: primaryColor,
                    activeColor: secondaryColor,
                  ),
                  const Text('Sahiplendirildi'),
                ],
              ),
              const SizedBox(height: 1),
              Container(
                margin: const EdgeInsets.all(16),
                height: 45,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: TextButton(
                  onPressed: _createAnimalAdoption,
                  child: const Text(
                    'İlanı Oluştur',
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
