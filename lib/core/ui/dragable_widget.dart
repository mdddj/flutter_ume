part of '../../flutter_ume_plus.dart';

typedef CanAccept = bool Function(int oldIndex, int newIndex);

typedef DragCompletion<T> = void Function(List<T?>? data);

typedef DataWidgetBuilder<T> = Widget Function(BuildContext context, T data);

class DragableGridView<T> extends StatefulWidget {
  final DataWidgetBuilder<T> itemBuilder;
  final CanAccept canAccept;
  final List<T> dataList;
  final int crossAxisCount;
  final Axis scrollDirection;
  final double childAspectRatio;
  final DragCompletion? dragCompletion;

  const DragableGridView(
    this.dataList, {
    Key? key,
    this.scrollDirection = Axis.vertical,
    this.crossAxisCount = 3,
    this.childAspectRatio = 1.0,
    this.dragCompletion,
    required this.itemBuilder,
    required this.canAccept,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DragableGridViewState<T>();
}

class _DragableGridViewState<T> extends State<DragableGridView> {
  List<T?>? dataList;
  late List<T?> dataListBackup;
  bool showItemWhenCovered = false;
  int willAcceptIndex = -1;
  int draggingItemIndex = -1;

  @override
  void initState() {
    super.initState();
    dataList = widget.dataList as List<T?>?;
    dataListBackup = dataList!.sublist(0);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: dataList!.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 0.85),
        itemBuilder: (_buildDraggable));
  }

  Widget _buildDraggable(BuildContext context, int index) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return LongPressDraggable(
          data: index,
          onDragStarted: () {
            draggingItemIndex = index;
            dataListBackup = dataList!.sublist(0);
          },
          onDraggableCanceled: (Velocity velocity, Offset offset) {
            setState(() {
              willAcceptIndex = -1;
              showItemWhenCovered = false;
              dataList = dataListBackup.sublist(0);
            });
          },
          onDragCompleted: () {
            if (widget.dragCompletion != null) {
              widget.dragCompletion!(dataList);
            }
            setState(() {
              showItemWhenCovered = false;
              willAcceptIndex = -1;
            });
          },
          feedback: Container(
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  blurRadius: 18,
                  spreadRadius: 0.8,
                  color: Colors.black87,
                ),
              ],
              borderRadius: BorderRadius.circular(6),
            ),
            child: SizedBox(
              width: constraint.maxWidth,
              height: constraint.maxHeight,
              child: widget.itemBuilder(context, dataList![index]),
            ),
          ),
          childWhenDragging: SizedBox(
            child: showItemWhenCovered
                ? widget.itemBuilder(context, dataList![index])
                : null,
          ),
          child: DragTarget<int>(
            onAcceptWithDetails: (_) {},
            builder: (context, data, rejects) {
              return willAcceptIndex >= 0 && willAcceptIndex == index
                  ? Container()
                  : widget.itemBuilder(context, dataList![index]);
            },
            onLeave: (_) {
              willAcceptIndex = -1;
              setState(() {
                showItemWhenCovered = false;
                dataList = dataListBackup.sublist(0);
              });
            },
            onWillAcceptWithDetails: (DragTargetDetails<int>? detail) {
              final fromIndex = detail?.data;
              final accept = fromIndex != index;
              if (accept) {
                willAcceptIndex = index;
                showItemWhenCovered = true;
                dataList = dataListBackup.sublist(0);
                final fromData = dataList![fromIndex!];
                setState(() {
                  dataList!.removeAt(fromIndex);
                  dataList!.insert(index, fromData);
                });
              }
              return accept;
            },
          ),
        );
      },
    );
  }
}
