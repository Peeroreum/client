import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';

/// 커스텀 갤러리 피커를 바텀시트로 표시합니다.
/// [multiple] false이면 1장만 선택 가능합니다.
/// [maxCount] 최대 선택 가능 장수 (multiple=true일 때 적용).
/// 반환값: 선택된 XFile 리스트, 취소 시 null
Future<List<XFile>?> showCustomImagePicker(
  BuildContext context, {
  bool multiple = true,
  int maxCount = 10,
}) {
  return showModalBottomSheet<List<XFile>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _CustomImagePickerSheet(
      multiple: multiple,
      maxCount: maxCount,
    ),
  );
}

class _CustomImagePickerSheet extends StatefulWidget {
  final bool multiple;
  final int maxCount;

  const _CustomImagePickerSheet({
    required this.multiple,
    required this.maxCount,
  });

  @override
  State<_CustomImagePickerSheet> createState() =>
      _CustomImagePickerSheetState();
}

class _CustomImagePickerSheetState extends State<_CustomImagePickerSheet> {
  List<AssetPathEntity> _albums = [];
  AssetPathEntity? _selectedAlbum;
  List<AssetEntity> _photos = [];
  final List<AssetEntity> _selectedPhotos = [];
  final Map<String, Future<Uint8List?>> _thumbnailCache = {};
  bool _loading = true;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth && !ps.hasAccess) {
      if (mounted) {
        setState(() {
          _loading = false;
          _permissionDenied = true;
        });
      }
      return;
    }
    _albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup(
        orders: [const OrderOption(type: OrderOptionType.createDate, asc: false)],
      ),
    );
    if (_albums.isNotEmpty) {
      _selectedAlbum = _albums.first;
      await _loadPhotos();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadPhotos() async {
    if (_selectedAlbum == null) return;
    final count = await _selectedAlbum!.assetCountAsync;
    final photos = await _selectedAlbum!.getAssetListPaged(
      page: 0,
      size: min(count, 300),
    );
    _thumbnailCache.clear();
    if (mounted) setState(() => _photos = photos);
  }

  Future<Uint8List?> _getThumbnail(AssetEntity asset) {
    return _thumbnailCache.putIfAbsent(
      asset.id,
      () => asset.thumbnailDataWithSize(const ThumbnailSize(300, 300)),
    );
  }

  void _toggleSelection(AssetEntity photo) {
    setState(() {
      if (_selectedPhotos.contains(photo)) {
        _selectedPhotos.remove(photo);
      } else {
        if (!widget.multiple) {
          _selectedPhotos.clear();
          _selectedPhotos.add(photo);
        } else if (_selectedPhotos.length < widget.maxCount) {
          _selectedPhotos.add(photo);
        }
      }
    });
  }

  Future<void> _onCameraTap() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null && mounted) {
      Navigator.pop(context, [image]);
    }
  }

  Future<void> _onAttach() async {
    final files = <XFile>[];
    for (final asset in _selectedPhotos) {
      final file = await asset.file;
      if (file != null) files.add(XFile(file.path));
    }
    if (mounted) Navigator.pop(context, files);
  }

  void _showAlbumSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => ListView.builder(
        shrinkWrap: true,
        itemCount: _albums.length,
        itemBuilder: (ctx, i) {
          final album = _albums[i];
          final isSelected = album == _selectedAlbum;
          return ListTile(
            title: Text(
              album.name,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 16,
                color: isSelected
                    ? PeeroreumColor.primaryPuple[400]
                    : PeeroreumColor.black,
              ),
            ),
            trailing: isSelected
                ? Icon(Icons.check, color: PeeroreumColor.primaryPuple[400])
                : null,
            onTap: () async {
              Navigator.pop(ctx);
              setState(() {
                _selectedAlbum = album;
                _photos = [];
                _loading = true;
              });
              await _loadPhotos();
              if (mounted) setState(() => _loading = false);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.92,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // 핸들 바
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 상단 바
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.close,
                          color: PeeroreumColor.gray[800]),
                      onPressed: () => Navigator.pop(context, null),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _albums.length > 1
                            ? _showAlbumSelector
                            : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _selectedAlbum?.name ?? '모두 보기',
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            if (_albums.length > 1)
                              const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed:
                          _selectedPhotos.isNotEmpty ? _onAttach : null,
                      child: Text(
                        '첨부',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: _selectedPhotos.isNotEmpty
                              ? PeeroreumColor.black
                              : PeeroreumColor.gray[400],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: PeeroreumColor.gray[100]),
              // 사진 그리드
              Expanded(
                child: _permissionDenied
                    ? _buildPermissionDenied()
                    : _loading
                        ? const Center(child: CircularProgressIndicator())
                        : GridView.builder(
                            controller: scrollController,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 2,
                              mainAxisSpacing: 2,
                            ),
                            itemCount: _photos.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) return _buildCameraCell();
                              return _buildPhotoCell(_photos[index - 1]);
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCameraCell() {
    return GestureDetector(
      onTap: _onCameraTap,
      child: Container(
        color: PeeroreumColor.gray[100],
        child: Icon(
          Icons.camera_alt_outlined,
          size: 36,
          color: PeeroreumColor.gray[600],
        ),
      ),
    );
  }

  Widget _buildPhotoCell(AssetEntity asset) {
    final isSelected = _selectedPhotos.contains(asset);
    final selectionIndex = _selectedPhotos.indexOf(asset);

    return GestureDetector(
      onTap: () => _toggleSelection(asset),
      child: Stack(
        fit: StackFit.expand,
        children: [
          FutureBuilder<Uint8List?>(
            future: _getThumbnail(asset),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Container(color: PeeroreumColor.gray[100]);
              }
              return Image.memory(snapshot.data!, fit: BoxFit.cover);
            },
          ),
          if (isSelected)
            Container(color: Colors.black.withOpacity(0.25)),
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Colors.black.withOpacity(0.55)
                    : Colors.transparent,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: isSelected
                  ? Center(
                      child: Text(
                        '${selectionIndex + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined,
              size: 48, color: PeeroreumColor.gray[400]),
          const SizedBox(height: 12),
          Text(
            '사진 접근 권한이 필요합니다.',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              color: PeeroreumColor.gray[600],
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => PhotoManager.openSetting(),
            child: Text(
              '설정으로 이동',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                color: PeeroreumColor.primaryPuple[400],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
