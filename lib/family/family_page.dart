// lib/family/family_page.dart
import 'package:flutter/material.dart';
import 'family_model.dart';
import 'family_painter.dart';
import 'family_detail_page.dart';
import 'family_controller.dart';

class FamilyPage extends StatefulWidget {
  const FamilyPage({super.key});

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  final TransformationController _transformationController = TransformationController();
  final FamilyController _controller = FamilyController();
  FamilyMember? _selectedMember;

  // 캔버스 크기 (무한 스크롤 느낌을 위해 화면보다 훨씬 크게 설정)
  static const double canvasSize = 4000;
  static const double center = canvasSize / 2;

  @override
  void initState() {
    super.initState();
    // 화면이 처음 그려진 직후, 시점을 중앙(나: 0,0)으로 이동시킴
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetView();
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  // 화면 초기화: 캔버스의 중심이 기기 화면의 중심에 오도록 좌표 조정
  void _resetView() {
    final size = MediaQuery.of(context).size;
    final double x = (size.width / 2) - center;
    final double y = (size.height / 2) - center;
    _transformationController.value = Matrix4.identity()..translate(x, y);
  }

  // 화면 갱신 (데이터 변경 시 호출)
  void _refresh() {
    setState(() {});
  }

  // [NEW] 가족 정보 수정 다이얼로그
  void _showEditDialog(FamilyMember member) {
    final nameCtr = TextEditingController(text: member.name);
    final relationCtr = TextEditingController(text: member.relation);
    final descCtr = TextEditingController(text: member.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("가족 정보 수정"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtr, decoration: const InputDecoration(labelText: "이름")),
                TextField(controller: relationCtr, decoration: const InputDecoration(labelText: "관계")),
                TextField(controller: descCtr, decoration: const InputDecoration(labelText: "설명")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소")),
            ElevatedButton(
              onPressed: () {
                if (nameCtr.text.isEmpty) return;

                final updatedMember = FamilyMember(
                  id: member.id,
                  name: nameCtr.text,
                  relation: relationCtr.text,
                  description: descCtr.text,
                  imageUrl: member.imageUrl,
                  position: member.position,
                  childrenIds: member.childrenIds,
                  spouseId: member.spouseId,
                );

                _controller.updateMember(updatedMember);
                setState(() {
                  _selectedMember = updatedMember;
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("수정되었습니다!")));
              },
              child: const Text("저장"),
            ),
          ],
        );
      },
    );
  }

  // 가족 추가 다이얼로그
  void _showAddDialog() {
    final nameCtr = TextEditingController();
    final relationCtr = TextEditingController();
    final descCtr = TextEditingController();

    String? selectedRelatedId = _selectedMember?.id;
    String? selectedSpouseId;
    int addMode = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("가족 추가하기"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedMember != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "기준: ${_selectedMember!.name} (${_selectedMember!.relation})",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade900),
                            ),
                            const SizedBox(height: 10),
                            // 3가지 선택지 균등 분할
                            Row(
                              children: [
                                Expanded(
                                  child: ChoiceChip(
                                    label: const Center(
                                        child: Text("자녀로",
                                          style: TextStyle(fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        )
                                    ),
                                    selected: addMode == 0,
                                    onSelected: (val) => setDialogState(() => addMode = 0),
                                    selectedColor: Colors.blue.shade100,
                                    showCheckmark: false,
                                    labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: ChoiceChip(
                                    label: const Center(
                                        child: Text("부모로",
                                          style: TextStyle(fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        )
                                    ),
                                    selected: addMode == 1,
                                    onSelected: (val) => setDialogState(() => addMode = 1),
                                    selectedColor: Colors.orange.shade100,
                                    showCheckmark: false,
                                    labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: ChoiceChip(
                                    label: const Center(
                                        child: Text("배우자로",
                                          style: TextStyle(fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        )
                                    ),
                                    selected: addMode == 2,
                                    onSelected: (val) => setDialogState(() => addMode = 2),
                                    selectedColor: Colors.pink.shade100,
                                    showCheckmark: false,
                                    labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    TextField(controller: nameCtr, decoration: const InputDecoration(labelText: "이름", hintText: "예: 홍길동")),
                    TextField(controller: relationCtr, decoration: const InputDecoration(labelText: "관계", hintText: "예: 고모")),
                    TextField(controller: descCtr, decoration: const InputDecoration(labelText: "설명", hintText: "예: 부산 거주")),

                    const SizedBox(height: 16),

                    if (_selectedMember == null) ...[
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: "연결할 가족 선택", border: OutlineInputBorder()),
                        value: selectedRelatedId,
                        items: [
                          const DropdownMenuItem(value: null, child: Text("선택안함 (독립)")),
                          ..._controller.members.map((m) {
                            return DropdownMenuItem(value: m.id, child: Text("${m.relation} (${m.name})"));
                          }),
                        ],
                        onChanged: (val) => setDialogState(() => selectedRelatedId = val),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: "배우자 선택", border: OutlineInputBorder()),
                        value: selectedSpouseId,
                        items: [
                          const DropdownMenuItem(value: null, child: Text("선택안함")),
                          ..._controller.members.map((m) {
                            return DropdownMenuItem(value: m.id, child: Text("${m.relation} (${m.name})"));
                          }),
                        ],
                        onChanged: (val) => setDialogState(() => selectedSpouseId = val),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소")),
                ElevatedButton(
                  onPressed: () {
                    if (nameCtr.text.isEmpty) return;

                    String? targetRelatedId = selectedRelatedId;
                    String? targetSpouseId = selectedSpouseId;
                    bool isParentMode = false;

                    if (_selectedMember != null) {
                      if (addMode == 0) { // 자녀로
                        targetRelatedId = _selectedMember!.id;
                        isParentMode = false;
                      } else if (addMode == 1) { // 부모로
                        targetRelatedId = _selectedMember!.id;
                        isParentMode = true;
                      } else if (addMode == 2) { // 배우자로
                        targetRelatedId = null;
                        targetSpouseId = _selectedMember!.id;
                      }
                    }

                    _controller.addMember(
                      name: nameCtr.text,
                      relation: relationCtr.text,
                      description: descCtr.text,
                      relatedMemberId: targetRelatedId,
                      isAddAsParent: isParentMode,
                      spouseId: targetSpouseId,
                    );
                    Navigator.pop(context);
                    _refresh();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("추가되었습니다!")));
                  },
                  child: const Text("추가"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteSelectedMember() {
    if (_selectedMember == null) return;
    _controller.deleteMember(_selectedMember!.id);
    setState(() => _selectedMember = null);
  }

  void _goToDetailPage(FamilyMember member) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FamilyDetailPage(
          member: member,
          allMembers: _controller.members,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final members = _controller.members;
    final double fabBottomPosition = _selectedMember != null ? 240.0 : 20.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("우리집 꿀범벅 가족"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. 맵 영역
          GestureDetector(
            onTap: () => setState(() => _selectedMember = null),
            child: InteractiveViewer(
              transformationController: _transformationController,
              boundaryMargin: const EdgeInsets.all(double.infinity),
              minScale: 0.1,
              maxScale: 3.0,
              constrained: false,
              child: SizedBox(
                width: canvasSize,
                height: canvasSize,
                child: Stack(
                  children: [
                    // 전체화면 크기의 CustomPaint (터치 영역 확보 및 그리기)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: FamilyTreePainter(
                          members: members,
                          // [중요] 페인터에게 캔버스 중심 오프셋을 전달해야
                          // 2000,2000 위치에 있는 노드들과 좌표가 일치하게 됩니다.
                          offset: const Offset(center, center),
                        ),
                      ),
                    ),
                    // 가족 노드들 배치
                    ...members.map((member) {
                      final isSelected = _selectedMember?.id == member.id;
                      return Positioned(
                        left: center + member.position.dx - 60,
                        top: center + member.position.dy - 80,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedMember = member);
                          },
                          onLongPress: () {
                            setState(() => _selectedMember = member);
                            _deleteSelectedMember();
                          },
                          child: _buildNode(member, isSelected),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),

          // 2. 우측 하단 플로팅 버튼들
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            right: 20,
            bottom: fabBottomPosition,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: "reset",
                  onPressed: _resetView,
                  backgroundColor: Colors.white,
                  tooltip: "중앙으로 이동",
                  child: const Icon(Icons.center_focus_strong, color: Colors.indigo),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "add",
                  onPressed: _showAddDialog,
                  backgroundColor: Colors.indigo,
                  tooltip: "가족 추가",
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),

          // 3. 하단 요약 카드
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: 0,
            right: 0,
            bottom: _selectedMember != null ? 0 : -250,
            child: _selectedMember != null
                ? _buildSummaryCard(_selectedMember!)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildNode(FamilyMember member, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 120, height: 160,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFF8F5F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isSelected ? Colors.deepOrange : Colors.grey.shade300,
            width: isSelected ? 2 : 1
        ),
        boxShadow: isSelected
            ? [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
            : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(member.relation, style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey[600],
          )),
          const SizedBox(height: 8),
          CircleAvatar(
            radius: 35,
            backgroundColor: isSelected ? Colors.white.withOpacity(0.3) : Colors.grey.shade100,
            child: Icon(Icons.person, size: 36, color: isSelected ? Colors.white : Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(member.name, style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black87,
          )),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(FamilyMember member) {
    return Container(
      height: 220,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _goToDetailPage(member),
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0EB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.person, size: 40, color: Color(0xFFFF8F5F)),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(member.relation, style: const TextStyle(color: Color(0xFFFF8F5F), fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text(member.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text(member.description, style: const TextStyle(color: Colors.grey), maxLines: 1),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showEditDialog(member),
                  icon: const Icon(Icons.edit, size: 18, color: Colors.blueAccent),
                  label: const Text("수정하기", style: TextStyle(color: Colors.blueAccent)),
                ),
              ),
              Container(width: 1, height: 24, color: Colors.grey.shade300),
              Expanded(
                child: TextButton.icon(
                  onPressed: _deleteSelectedMember,
                  icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent),
                  label: const Text("삭제하기", style: TextStyle(color: Colors.redAccent)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}