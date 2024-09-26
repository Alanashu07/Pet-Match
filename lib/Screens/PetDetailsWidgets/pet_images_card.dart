import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Constants/global_variables.dart';
import '../../Models/pet_model.dart';
import '../../image_viewer.dart';

class PetImagesCard extends StatefulWidget {
  final PetModel pet;

  const PetImagesCard({super.key, required this.pet});

  @override
  State<PetImagesCard> createState() => _PetImagesCardState();
}

class _PetImagesCardState extends State<PetImagesCard> {

  @override
  Widget build(BuildContext context) {
    bool isLiked = context.watch<GlobalVariables>().user.favouritePets.contains(widget.pet.id);
    bool isOwner = widget.pet.ownerId == GlobalVariables.currentUser!.id;
    final mq = MediaQuery.of(context).size;
    return SizedBox(
      height: mq.height*.4,
      child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_)=> ImageViewer(title: widget.pet.name, image: widget.pet.images[index])));
              },
              child: Container(
                alignment: Alignment.topRight,
                width: mq.width*.95, height: mq.height*.4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(image: NetworkImage(widget.pet.images[index]), fit: BoxFit.cover),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: isOwner ? CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: IconButton(onPressed: (){
                      showDialog(context: context, builder: (context) => AlertDialog(
                        title: const Text('Sure to delete?'),
                        content: const Text('Are you sure to delete the image?'),
                        actions: [
                          TextButton(onPressed: (){
                            Navigator.pop(context);
                            context.read<GlobalVariables>().deletePetImage(pet: widget.pet, image: widget.pet.images[index]);
                          }, child: const Text('Delete')),
                          TextButton(onPressed: (){
                            Navigator.pop(context);
                          }, child: const Text('Cancel')),
                        ],
                      ),);
                    }, icon: const Icon(CupertinoIcons.delete)),
                  ) : CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: IconButton(onPressed: (){
                      context.read<GlobalVariables>().addToFavorite(petId: widget.pet.id!);
                    }, icon: isLiked ? const Icon(Icons.favorite, color: Colors.red,) : const Icon(Icons.favorite_border, color: Colors.grey,)),
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(
                width: 20,
              ),
          itemCount: widget.pet.images.length),
    );
  }
}
