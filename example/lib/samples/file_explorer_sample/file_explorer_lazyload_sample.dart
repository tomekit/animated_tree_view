import 'dart:math';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Explorer Lazy Load Sample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'File Explorer Lazy Load Sample'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final globalKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: TreeView.simpleTyped<Explorable, TreeNode<Explorable>>(
          tree: tree,
          showRootNode: true,
          onItemTap: (node) async {
            // This emulates load after 500ms
            // if (node.childrenAsList.isEmpty && node is FolderNode) { // node.isExpanded
            //   await Future.delayed(Duration(milliseconds: 500));
            //   node.add(FolderNode(data: Folder("Subfolder")));
            //   node.add(FileNode(data: File("birthday_3.jpg", mimeType: "image/jpeg")));
            // }

            // This emulates load, but no results, so we set noResults = true to hide chevron.
            if (node.childrenAsList.isEmpty && node is FolderNode) { // node.isExpanded
              node.data!.noResults = true;
              node.notify();
            }
          },
          expansionBehavior: ExpansionBehavior.snapToTop,
          // showExpansionIndicatorWhenEmpty: true,
          expansionIndicatorBuilder: (context, node) {
            if (node.isRoot) {
              return PlusMinusIndicator(
                tree: node,
                alignment: Alignment.centerLeft,
                color: Colors.grey[700],
              );
            } else {
              if (node is FolderNode && node.data?.noResults != true) {
                return ChevronIndicator.rightDown(
                  tree: node,
                  alignment: Alignment.centerLeft,
                  color: Colors.grey[700],
                );
              } else {
                return NoExpansionIndicator(tree: node);
              }
            }
          },
          indentation: const Indentation(),
          builder: (context, node) => Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: ListTile(
              title: Text(node.data?.name ?? "N/A"),
              subtitle: Text(node.data?.createdAt.toString() ?? "N/A"),
              leading: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: node.icon,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension on ExplorableNode {
  Icon get icon {
    if (isRoot) return Icon(Icons.data_object);

    if (this is FolderNode) {
      if (isExpanded) return Icon(Icons.folder_open);
      return Icon(Icons.folder);
    }

    if (this is FileNode) {
      final file = this.data as File;
      if (file.mimeType.startsWith("image")) return Icon(Icons.image);
      if (file.mimeType.startsWith("video")) return Icon(Icons.video_file);
    }

    return Icon(Icons.insert_drive_file);
  }
}

abstract class Explorable {
  final String name;
  final DateTime createdAt;

  Explorable(this.name) : this.createdAt = DateTime.now();

  @override
  String toString() => name;
}

class File extends Explorable {
  final String mimeType;
  File(super.name, {required this.mimeType});
}

class Folder extends Explorable {
  bool? noResults;

  Folder(super.name);
}

typedef ExplorableNode = TreeNode<Explorable>;
typedef FileNode = TreeNode<File>;
typedef FolderNode = TreeNode<Folder>;

final tree = TreeNode<Explorable>.root(data: Folder("/root"))
  ..addAll([
    FolderNode(data: Folder("Documents")),
  ]);
