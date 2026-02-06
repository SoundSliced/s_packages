import 'package:flutter/material.dart';
import 'package:s_client/s_client.dart';

class TypedResponseTestScreen extends StatefulWidget {
  const TypedResponseTestScreen({super.key});

  @override
  State<TypedResponseTestScreen> createState() =>
      _TypedResponseTestScreenState();
}

class _TypedResponseTestScreenState extends State<TypedResponseTestScreen> {
  bool _isLoadingHttp = false;
  bool _isLoadingDio = false;
  List<Post>? _httpPosts;
  List<Post>? _dioPosts;
  Post? _httpCreatedPost;
  Post? _dioCreatedPost;
  String? _httpError;
  String? _dioError;
  int? _httpDuration;
  int? _dioDuration;
  String _selectedTest = 'list';

  Future<void> _runGetListTest({required ClientType clientType}) async {
    final isHttp = clientType == ClientType.http;
    setState(() {
      if (isHttp) {
        _isLoadingHttp = true;
        _httpPosts = null;
        _httpCreatedPost = null;
        _httpError = null;
        _httpDuration = null;
      } else {
        _isLoadingDio = true;
        _dioPosts = null;
        _dioCreatedPost = null;
        _dioError = null;
        _dioDuration = null;
      }
    });

    final stopwatch = Stopwatch()..start();

    // Using getJsonList with callbacks to automatically parse a list of typed objects
    await SClient.instance.getJsonList<Post>(
      url: 'https://jsonplaceholder.typicode.com/posts',
      queryParameters: {'_limit': '5'},
      fromJson: Post.fromJson,
      clientType: clientType,
      onSuccess: (posts, response) {
        stopwatch.stop();
        setState(() {
          if (isHttp) {
            _isLoadingHttp = false;
            _httpPosts = posts;
            _httpDuration = stopwatch.elapsedMilliseconds;
          } else {
            _isLoadingDio = false;
            _dioPosts = posts;
            _dioDuration = stopwatch.elapsedMilliseconds;
          }
        });
      },
      onError: (error) {
        stopwatch.stop();
        setState(() {
          if (isHttp) {
            _isLoadingHttp = false;
            _httpError = error.toString();
            _httpDuration = stopwatch.elapsedMilliseconds;
          } else {
            _isLoadingDio = false;
            _dioError = error.toString();
            _dioDuration = stopwatch.elapsedMilliseconds;
          }
        });
      },
    );
  }

  Future<void> _runGetSingleTest({required ClientType clientType}) async {
    final isHttp = clientType == ClientType.http;
    setState(() {
      if (isHttp) {
        _isLoadingHttp = true;
        _httpPosts = null;
        _httpCreatedPost = null;
        _httpError = null;
        _httpDuration = null;
      } else {
        _isLoadingDio = true;
        _dioPosts = null;
        _dioCreatedPost = null;
        _dioError = null;
        _dioDuration = null;
      }
    });

    final stopwatch = Stopwatch()..start();

    // Using getJson with callbacks to get a single typed object
    await SClient.instance.getJson<Post>(
      url: 'https://jsonplaceholder.typicode.com/posts/1',
      fromJson: Post.fromJson,
      clientType: clientType,
      onSuccess: (post, response) {
        stopwatch.stop();
        setState(() {
          if (isHttp) {
            _isLoadingHttp = false;
            _httpPosts = [post];
            _httpDuration = stopwatch.elapsedMilliseconds;
          } else {
            _isLoadingDio = false;
            _dioPosts = [post];
            _dioDuration = stopwatch.elapsedMilliseconds;
          }
        });
      },
      onError: (error) {
        stopwatch.stop();
        setState(() {
          if (isHttp) {
            _isLoadingHttp = false;
            _httpError = error.toString();
            _httpDuration = stopwatch.elapsedMilliseconds;
          } else {
            _isLoadingDio = false;
            _dioError = error.toString();
            _dioDuration = stopwatch.elapsedMilliseconds;
          }
        });
      },
    );
  }

  Future<void> _runPostJsonTest({required ClientType clientType}) async {
    final isHttp = clientType == ClientType.http;
    setState(() {
      if (isHttp) {
        _isLoadingHttp = true;
        _httpPosts = null;
        _httpCreatedPost = null;
        _httpError = null;
        _httpDuration = null;
      } else {
        _isLoadingDio = true;
        _dioPosts = null;
        _dioCreatedPost = null;
        _dioError = null;
        _dioDuration = null;
      }
    });

    final stopwatch = Stopwatch()..start();

    // Using postJson with callbacks to create and get back a typed object
    await SClient.instance.postJson<Post>(
      url: 'https://jsonplaceholder.typicode.com/posts',
      body: {
        'title': 'New Post from s_client',
        'body': 'This post was created using the typed postJson method!',
        'userId': 1,
      },
      fromJson: Post.fromJson,
      clientType: clientType,
      onSuccess: (post, response) {
        stopwatch.stop();
        setState(() {
          if (isHttp) {
            _isLoadingHttp = false;
            _httpCreatedPost = post;
            _httpDuration = stopwatch.elapsedMilliseconds;
          } else {
            _isLoadingDio = false;
            _dioCreatedPost = post;
            _dioDuration = stopwatch.elapsedMilliseconds;
          }
        });
      },
      onError: (error) {
        stopwatch.stop();
        setState(() {
          if (isHttp) {
            _isLoadingHttp = false;
            _httpError = error.toString();
            _httpDuration = stopwatch.elapsedMilliseconds;
          } else {
            _isLoadingDio = false;
            _dioError = error.toString();
            _dioDuration = stopwatch.elapsedMilliseconds;
          }
        });
      },
    );
  }

  void _runSelectedTest({required ClientType clientType}) {
    switch (_selectedTest) {
      case 'list':
        _runGetListTest(clientType: clientType);
        break;
      case 'single':
        _runGetSingleTest(clientType: clientType);
        break;
      case 'create':
        _runPostJsonTest(clientType: clientType);
        break;
    }
  }

  Future<void> _runBothTests() async {
    switch (_selectedTest) {
      case 'list':
        await Future.wait([
          _runGetListTest(clientType: ClientType.http),
          _runGetListTest(clientType: ClientType.dio),
        ]);
        break;
      case 'single':
        await Future.wait([
          _runGetSingleTest(clientType: ClientType.http),
          _runGetSingleTest(clientType: ClientType.dio),
        ]);
        break;
      case 'create':
        await Future.wait([
          _runPostJsonTest(clientType: ClientType.http),
          _runPostJsonTest(clientType: ClientType.dio),
        ]);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Typed Responses'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test: Typed JSON Parsing',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Demonstrates parsing JSON responses directly into Dart model classes '
              'using getJson, getJsonList, and postJson methods.',
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Test:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    RadioGroup<String>(
                      groupValue: _selectedTest,
                      onChanged: (v) => setState(() => _selectedTest = v!),
                      child: const Column(
                        children: [
                          RadioListTile<String>(
                            title: Text('getJsonList<Post>'),
                            subtitle: Text('Fetch list of posts'),
                            value: 'list',
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                          RadioListTile<String>(
                            title: Text('getJson<Post>'),
                            subtitle: Text('Fetch single post by ID'),
                            value: 'single',
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                          RadioListTile<String>(
                            title: Text('postJson<Post>'),
                            subtitle: Text('Create and return typed post'),
                            value: 'create',
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              color: Colors.blue[50],
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Post Model:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(
                      'class Post {\n'
                      '  final int id;\n'
                      '  final int userId;\n'
                      '  final String title;\n'
                      '  final String body;\n'
                      '}',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoadingHttp
                        ? null
                        : () => _runSelectedTest(clientType: ClientType.http),
                    icon: _isLoadingHttp
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.http, size: 18),
                    label: const Text('HTTP'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade100,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoadingDio
                        ? null
                        : () => _runSelectedTest(clientType: ClientType.dio),
                    icon: _isLoadingDio
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.rocket_launch, size: 18),
                    label: const Text('Dio'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_isLoadingHttp || _isLoadingDio)
                        ? null
                        : _runBothTests,
                    icon: (_isLoadingHttp || _isLoadingDio)
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.compare_arrows, size: 18),
                    label: const Text('Both'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.http, size: 16),
                              const SizedBox(width: 4),
                              const Text(
                                'HTTP',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              if (_httpDuration != null)
                                Text(
                                  '${_httpDuration}ms',
                                  style: const TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _buildResultsPanel(
                            posts: _httpPosts,
                            createdPost: _httpCreatedPost,
                            error: _httpError,
                            isLoading: _isLoadingHttp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.rocket_launch, size: 16),
                              const SizedBox(width: 4),
                              const Text(
                                'Dio',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              if (_dioDuration != null)
                                Text(
                                  '${_dioDuration}ms',
                                  style: const TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _buildResultsPanel(
                            posts: _dioPosts,
                            createdPost: _dioCreatedPost,
                            error: _dioError,
                            isLoading: _isLoadingDio,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsPanel({
    required List<Post>? posts,
    required Post? createdPost,
    required String? error,
    required bool isLoading,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Card(
        color: Colors.red[50],
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.error, color: Colors.red[700], size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Error',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(error, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      );
    }

    if (createdPost != null) {
      return Card(
        color: Colors.green[50],
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Created Post',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Divider(),
              _PostCard(post: createdPost),
            ],
          ),
        ),
      );
    }

    if (posts != null) {
      return Card(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                '${posts.length} posts',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return _PostCard(post: posts[index]);
                },
              ),
            ),
          ],
        ),
      );
    }

    return const Center(
      child: Text(
        'Run a test',
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }
}

/// Example model class for demonstrating typed responses
class Post {
  final int id;
  final int userId;
  final String title;
  final String body;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'ID: ${post.id}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[700],
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'User: ${post.userId}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              post.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              post.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
