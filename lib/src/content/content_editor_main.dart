import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callout_api/callout_api.dart';
import 'package:flutter_callout_api/src/content/bloc/node_editor_bloc.dart';
import 'package:flutter_callout_api/src/content/mappable_nodes/content_nodes.dart';
import 'package:flutter_callout_api/src/content/widgets/content_editor_wrapper.dart';
import 'package:flutter_callout_api/src/content/widgets/node_widget.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_strategy/url_strategy.dart';

const double CLIPBOARD_TAB_W = 400;
const double CLIPBOARD_TAB_H = 300;

class AppBlocObserver extends BlocObserver {
  AppBlocObserver();

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (bloc is Cubit) print(change);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print("onTransition: ${transition.event}");
    NodeEditorBloc ccBloc = bloc as NodeEditorBloc;
    NodeEditorState curr = transition.currentState as NodeEditorState;
    NodeEditorState next = transition.nextState as NodeEditorState;
    // TargetConfig? tc = next.selectedTarget;
    // if (tc != null) print()
    // // print("Rel Pos: ${tc?.childLocalPosLeftPc ?? 0.0}, ${tc?.childLocalPosTopPc ?? 0.0}");
    // // print("translate: ${tc?.getTranslate().toString()}  scale: ${tc?.getScale()}");
    // print("playList: ${next.playList.toString()}");
    // for (String iwName in next.imageTargetListMap.keys) {
    //   print("wrapper: $iwName");
    //   for (int i=0; i<(next.imageTargetListMap[iwName]??[]).length; i++) {
    //     print("           ($i)");
    //   }
    // }
    // print("lastupdated is ${next.lastUpdatedTC == null ? 'NULL' : 'not NULL'}");
    // print("ivRect.pos is ${next.ivRectMap[tc?.iwName]}");
  }
}

Iterable<Node> childrenProvider(Node node) {
  if (node is ChildlessNode) {
    return [];
  }
  if (node is SingleChildNode && node.child == null) {
    return [];
  }
  if (node is SingleChildNode && node.child != null) {
    return [node.child!];
  }
  if (node is MultiChildNode) {
    return node.children;
  }
  // unexpected
  return [];
}

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Sets the URL strategy of your web app to using paths instead of a leading hash (#).
  // You can safely call this on all platforms, i.e. also when running on mobile or desktop. In that case, it will simply be a noop.
  setPathUrlStrategy();

  // build the local storage (web hive or mobile device directory)
  Bloc.observer = AppBlocObserver();

  var dir = kIsWeb ? HydratedStorage.webStorageDirectory : await getTemporaryDirectory();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: dir,
  );

  await Useful.instance.initResponsive();
  // hide status bar
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ScrollController? vsc;
  ScrollController? hsc;

  @override
  void initState() {
    super.initState();
    // hsc = ScrollController();
    vsc = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    print("main build");
    return ContentEditorWrapper(
      initialValueJsonAssetPath: "callout-scripts/sample-config.json",
      localTestingFilePaths: true,
      runningInProduction: false,
      contentEditorF: (TreeController<Node> treeC) => const MaterialApp(
        home: Scaffold(
          body: ContentTreeStack(),
        ),
      ),
    );
  }
}

class ContentTreeStack extends StatelessWidget {
  const ContentTreeStack({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NodeEditorBloc, NodeEditorState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: (){
            NodeEditorBloc bloc = BlocProvider.of<NodeEditorBloc>(context);
            bloc.add(NodeEditorEvent.clearSelection());
          },
          child: SizedBox.fromSize(
            size: MediaQuery.of(context).size,
            child: Stack(
              children: [
                TreeView<Node>(
                  treeController: state.treeC,
                  nodeBuilder: (BuildContext context, TreeEntry<Node> entry) {
                    return TreeIndentation(
                      entry: entry,
                      child: NodeWidget(treeController: state.treeC, entry: entry),
                    );
                  },
                ),
                if (state.jsonClipboard != null) const PositionedClipboardTab(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PositionedClipboardTab extends StatelessWidget {
  const PositionedClipboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    NodeEditorBloc bloc = BlocProvider.of<NodeEditorBloc>(context);
    var clipboardNode = NodeMapper.fromJson(bloc.state.jsonClipboard!);
    TreeController<Node> clipboardTreeC = TreeController<Node>(
      roots: [clipboardNode],
      childrenProvider: childrenProvider,
    );
    //clipboardTreeC.expandCascading([clipboardNode]);
    return Positioned(
      top: 0,
      right: 200,
      child: SizedBox(
        width: CLIPBOARD_TAB_W,
        height: CLIPBOARD_TAB_H,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.lightBlueAccent,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black87, blurRadius: 3, spreadRadius: 2),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // CLIPBOARD NODE
              Expanded(
                child: InteractiveViewer(
                  child: TreeView<Node>(
                    treeController: clipboardTreeC,
                    nodeBuilder: (BuildContext context, TreeEntry<Node> entry) {
                      return TreeIndentation(
                        entry: entry,
                        child: NodeWidget(
                          treeController: clipboardTreeC,
                          entry: entry,
                          onClipboard: true,
                        ),
                      );
                    },
                  ),
                ),
              ), // CLEAR CLIPBOARD BTN
              IconButton(
                tooltip: 'clear the clipboard',
                onPressed: () {
                  bloc.add(const NodeEditorEvent.clearClipboard());
                },
                icon: const Icon(
                  Icons.close,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
