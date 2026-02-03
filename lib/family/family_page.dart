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

  static const double canvasSize = 4000;
  static const double center = canvasSize / 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetView();
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _resetView() {
    final size = MediaQuery.of(context).size;
    final double x = (size.width / 2) - center;
    final double y = (size.height / 2) - center;
    _transformationController.value = Matrix4.identity()..translate(x, y);
  }

  void _refresh() {
    setState(() {});
  }

  // 가족 추가 다이얼로그
  void _showAddDialog() {
    final nameCtr = TextEditingController();
    final relationCtr = TextEditingController();
    final descCtr = TextEditingController();

    // 기본값 설정
    String? selectedRelatedId = _selectedMember?.id;
    String? selectedSpouseId;

    // 추가 모드 (0: 자녀, 1: 부모, 2: 배우자)
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
                    // 1. 기준 인물이 있을 때: 관계 선택 (3가지 옵션)
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

                            // [수정됨] 버튼을 Expanded로 감싸서 균등 분할
                            Row(
                              children: [
                                Expanded(
                                  child: ChoiceChip(
                                    label: const Center(
                                        child: Text("자녀로", style: TextStyle(fontSize: 12))
                                    ),
                                    selected: addMode == 0,
                                    onSelected: (val) => setDialogState(() => addMode = 0),
                                    selectedColor: Colors.blue.shade100,
                                    showCheckmark: false, // 공간 확보를 위해 체크 표시 숨김
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: ChoiceChip(
                                    label: const Center(
                                        child: Text("부모로", style: TextStyle(fontSize: 12))
                                    ),
                                    selected: addMode == 1,
                                    onSelected: (val) => setDialogState(() => addMode = 1),
                                    selectedColor: Colors.orange.shade100,
                                    showCheckmark: false,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: ChoiceChip(
                                    label: const Center(
                                        child: Text("배우자로", style: TextStyle(fontSize: 12))
                                    ),
                                    selected: addMode == 2,
                                    onSelected: (val) => setDialogState(() => addMode = 2),
                                    selectedColor: Colors.pink.shade100,
                                    showCheckmark: false,
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

                    // 기준 인물이 없을 때만 전체 선택 드롭다운 표시
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
                      // 배우자 별도 선택 (독립 추가 시)
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

                    // 모드에 따른 파라미터 설정
                    String? targetRelatedId = selectedRelatedId;
                    String? targetSpouseId = selectedSpouseId;
                    bool isParentMode = false;

                    if (_selectedMember != null) {
                      if (addMode == 0) { // 자녀로 추가
                        targetRelatedId = _selectedMember!.id;
                        isParentMode = false;
                      } else if (addMode == 1) { // 부모로 추가
                        targetRelatedId = _selectedMember!.id;
                        isParentMode = true;
                      } else if (addMode == 2) { // 배우자로 추가
                        targetRelatedId = null; // 부모/자녀 관계 아님
                        targetSpouseId = _selectedMember!.id; // 배우자로 연결
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
                    Positioned.fill(
                      child: CustomPaint(
                        painter: FamilyTreePainter(
                          members: members,
                          offset: const Offset(center, center),
                        ),
                      ),
                    ),
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

          // 3. 하단 요약 정보 카드
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
          const Divider(),
          InkWell(
            onTap: _deleteSelectedMember,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 16),
                  SizedBox(width: 6),
                  Text("가족 구성원 삭제", style: TextStyle(color: Colors.red, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}