import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/provider/imageprovider.dart';

class AccountTab extends ConsumerWidget {
  const AccountTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageState = ref.watch(imageProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage: imageState.imageBytes != null
                ? MemoryImage(imageState.imageBytes!)
                : const NetworkImage(
                        'https://www.kimirica.shop/cdn/shop/articles/Kiara_s-favourite-self-care-essentials-Blog-01.jpg?v=1690280478&width=2048',
                      )
                      as ImageProvider,

            maxRadius: 85,
            minRadius: 40,
          ),
          title: const Text('Profile'),
          subtitle: const Text('View and edit your profile information'),
          onTap: () {},
        ),
        const Divider(),
        const ListTile(
          title: Text('Change Password'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
        ),
        const ListTile(
          title: Text('Delete Account'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ],
    );
  }
}