// ignore_for_file: avoid_print

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pat_e/core/models/animal_adoption_model.dart';

class AnimalAdoptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // hayvan ilanı oluşturma
  Future createAnimalAdoption(AnimalAdoption animal, List<File> photo) async {
    try {
      // kullanıcının uid'sini almak için _auth.currentUser?.uid kullanma
      await _firestore
          .collection('users')
          .doc(_auth.currentUser
              ?.uid) // users koleksiyonundan uid'ye göre bir belge seçme
          .collection(
              'animaladoptions') // o belgenin altındaki animaladoptions koleksiyonuna erişme
          .doc(animal.animalID)
          .set(animal.toMap());

      // hayvanın fotoğraflarını storage'a yükleme ve linklerini alıp firestore'a kaydetme
      await uploadPhotosAndGetLinks(animal.animalID!, photo);
    } catch (e) {
      print(e.toString());
    }
  }

  // hayvan ilanı güncelleme
  Future updateAnimalAdoption(AnimalAdoption animal, List<File> photo) async {
    try {
      // kullanıcının uid'sini almak için _auth.currentUser?.uid kullanma
      await _firestore
          .collection('users')
          .doc(_auth.currentUser
              ?.uid) // users koleksiyonundan uid'ye göre bir belge seçme
          .collection(
              'animaladoptions') // o belgenin altındaki animaladoptions koleksiyonuna erişme
          .doc(animal.animalID)
          .update(animal.toMap());

      // hayvanın fotoğraflarını storage'a yükleme
      await uploadPhotosAndGetLinks(animal.animalID!, photo);
    } catch (e) {
      print(e.toString());
    }
  }

  // hayvan ilanı silme
  Future deleteAnimalAdoption(String animalID) async {
    try {
      // kullanıcının uid'sini almak için _auth.currentUser?.uid kullanma
      await _firestore
          .collection('users')
          .doc(_auth.currentUser
              ?.uid) // users koleksiyonundan uid'ye göre bir belge seçme
          .collection(
              'animaladoptions') // o belgenin altındaki animaladoptions koleksiyonuna erişme
          .doc(animalID)
          .delete();

      // hayvanın fotoğraflarını storage'dan silme
      await deletePhotos(animalID);
    } catch (e) {
      print(e.toString());
    }
  }

  // hayvan ilanı listesi getirme
  Future<List<AnimalAdoption>> getAnimalAdoptions() async {
    try {
      // tüm kullanıcıların ilanlarını getirmek için users koleksiyonunu değil, animaladoptions koleksiyon grubunu sorgulama
      QuerySnapshot query = await _firestore
          .collectionGroup(
              'animaladoptions') // animaladoptions koleksiyon grubunu seçme
          .orderBy('name')
          .get();
      List<AnimalAdoption> animals = query.docs
          .map((doc) =>
              AnimalAdoption.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      return animals;
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  // Kullanıcının kendi ilanlarını getiren özel bir fonksiyon
  Future<List<AnimalAdoption>> getUserAnimalAdoptions() async {
    try {
      String uid = _auth.currentUser!.uid;

      QuerySnapshot query = await _firestore
          .collection('users')
          .doc(uid)
          .collection('animaladoptions')
          .orderBy('name')
          .get();

      List<AnimalAdoption> animals = query.docs
          .map((doc) =>
              AnimalAdoption.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return animals;
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  // fotoğrafları storage'a yükleme ve linklerini alıp firestore'a kaydetme fonksiyonu
  Future uploadPhotosAndGetLinks(String animalID, List<File> photos) async {
    try {
      // linkleri tutmak için boş bir liste oluşturma
      List<String> links = [];
      for (int i = 0; i < photos.length; i++) {
        // fotoğrafı File olarak okuma
        File photo = photos[i];
        // storage'da referans oluşturma
        Reference ref = _storage
            .ref()
            .child('users')
            .child(_auth.currentUser!.uid)
            .child('animaladoptions')
            .child(animalID)
            .child('photos')
            .child('$i');
        // fotoğrafı storage'a yükleme
        UploadTask task = ref.putFile(photo);
        await task.whenComplete(() {});
        // fotoğrafın linkini alıp listeye ekleme
        String link = await ref.getDownloadURL();
        links.add(link);
      }
      // linkleri firestore'a kaydetme
      await _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('animaladoptions')
          .doc(animalID)
          .update({'photos': links});
    } catch (e) {
      print(e.toString());
    }
  }

  // fotoğrafları storage'dan silme fonksiyonu
  Future deletePhotos(String animalID) async {
    try {
      // storage'da referans oluşturma
      Reference ref = _storage
          .ref()
          .child('users')
          .child(_auth.currentUser!.uid)
          .child('animaladoptions')
          .child(animalID)
          .child('photos');
      // referansın altındaki tüm fotoğrafları listeleme
      ListResult result = await ref.listAll();
      for (Reference item in result.items) {
        // her bir fotoğrafı silme
        await item.delete();
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
