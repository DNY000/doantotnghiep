import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin/viewmodels/banner_viewmode.dart';
import 'package:admin/models/banner_model.dart';
import 'package:admin/reponsive.dart';
import 'package:admin/screens/main/components/side_menu.dart';

class BannerScreen extends StatelessWidget {
  const BannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add AppBar for mobile view
      appBar: Responsive.isMobile(context)
          ? AppBar(
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
              title: Text('Quản lý Banner',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white)),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
            )
          : null,
      // Use SideMenu as drawer on mobile
      drawer: Responsive.isMobile(context) ? const SideMenu() : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (Responsive.isDesktop(context))
            const Expanded(flex: 1, child: SideMenu()),
          const Expanded(
            flex: 5,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: BannerContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BannerContent extends StatefulWidget {
  const BannerContent({super.key});

  @override
  State<BannerContent> createState() => _BannerContentState();
}

class _BannerContentState extends State<BannerContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<BannerViewmode>().getListBanner());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Hide title on mobile as it's in AppBar
            if (!Responsive.isMobile(context))
              Text(
                'Quản lý Banner',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ElevatedButton.icon(
              onPressed: () {
                _showBannerDialog(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Thêm Banner'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Search section
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm banner...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 24),

        // Banner list
        Expanded(
          child: Consumer<BannerViewmode>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              var filteredBanners = viewModel.listBanner;

              // Apply search filter
              if (_searchController.text.isNotEmpty) {
                filteredBanners = filteredBanners
                    .where(
                      (banner) =>
                          banner.title.toLowerCase().contains(
                                _searchController.text.toLowerCase(),
                              ) ||
                          banner.subTitle.toLowerCase().contains(
                                _searchController.text.toLowerCase(),
                              ),
                    )
                    .toList();
              }

              if (filteredBanners.isEmpty) {
                return const Center(child: Text('Không tìm thấy banner nào'));
              }

              return Responsive.isDesktop(context)
                  ? _buildDesktopView(filteredBanners, viewModel)
                  : _buildMobileView(filteredBanners, viewModel);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopView(
    List<BannerModel> banners,
    BannerViewmode viewModel,
  ) {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Hình ảnh')),
          DataColumn(label: Text('Tiêu đề')),
          DataColumn(label: Text('Phụ đề')),
          DataColumn(label: Text('Link')),
          DataColumn(label: Text('Thao tác')),
        ],
        rows: banners.map((banner) {
          return DataRow(
            cells: [
              DataCell(
                banner.image.isNotEmpty
                    ? Image.network(
                        banner.image,
                        width: 100,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                          'assets/images/default_banner.png', // Replace with your default asset image
                          width: 100,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported),
                        ),
                      )
                    : const Icon(Icons.image_not_supported),
              ),
              DataCell(Text(banner.title)),
              DataCell(Text(banner.subTitle)),
              DataCell(Text(banner.link)),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showBannerDialog(context, banner);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Xác nhận xóa'),
                            content: Text(
                              'Bạn có chắc muốn xóa banner ${banner.title}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Xóa'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          await viewModel.deleteBanner(banner.id);
                          await viewModel.getListBanner();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileView(
    List<BannerModel> banners,
    BannerViewmode viewModel,
  ) {
    return ListView.builder(
      itemCount: banners.length,
      itemBuilder: (context, index) {
        final banner = banners[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (banner.image.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      banner.image,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/images/default_banner.png', // Replace with your default asset image
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          // Use Container as fallback for asset image
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  banner.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(banner.subTitle),
                const SizedBox(height: 8),
                Text('Link: ${banner.link}'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showBannerDialog(context, banner);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Xác nhận xóa'),
                            content: Text(
                              'Bạn có chắc muốn xóa banner ${banner.title}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Xóa'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          await viewModel.deleteBanner(banner.id);
                          await viewModel.getListBanner();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBannerDialog(BuildContext context, [BannerModel? banner]) {
    final viewModel = Provider.of<BannerViewmode>(context, listen: false);
    final TextEditingController titleController =
        TextEditingController(text: banner?.title ?? '');
    final TextEditingController subTitleController =
        TextEditingController(text: banner?.subTitle ?? '');
    final TextEditingController imageController =
        TextEditingController(text: banner?.image ?? '');
    final TextEditingController linkController =
        TextEditingController(text: banner?.link ?? '');
    String? errorText;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(banner == null ? 'Thêm Banner' : 'Sửa Banner'),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                width: MediaQuery.of(context).size.width * 0.5,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Tiêu đề',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: subTitleController,
                        decoration: const InputDecoration(
                          labelText: 'Phụ đề',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: imageController,
                        decoration: const InputDecoration(
                          labelText: 'URL Hình ảnh',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: linkController,
                        decoration: const InputDecoration(
                          labelText: 'Link',
                        ),
                      ),
                      if (errorText != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            errorText!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          setState(() {
                            errorText = null;
                          });

                          if (titleController.text.isEmpty) {
                            setState(() {
                              errorText = 'Tiêu đề không được để trống';
                            });
                            return;
                          }

                          if (imageController.text.isEmpty) {
                            setState(() {
                              errorText = 'URL hình ảnh không được để trống';
                            });
                            return;
                          }

                          final newBanner = BannerModel(
                            id: banner?.id ?? '',
                            title: titleController.text,
                            subTitle: subTitleController.text,
                            image: imageController.text,
                            link: linkController.text,
                          );

                          try {
                            if (banner == null) {
                              await viewModel.addBanner(newBanner);
                            } else {
                              await viewModel.updateBanner(
                                  newBanner, banner.id);
                            }
                            await viewModel.getListBanner();
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            setState(() {
                              errorText = e.toString();
                            });
                          }
                        },
                  child: viewModel.isLoading
                      ? const CircularProgressIndicator()
                      : Text(banner == null ? 'Thêm' : 'Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
