import 'package:flutter/material.dart';
import 'package:eventorize_app/data/repositories/user_repository.dart';
import 'package:eventorize_app/data/api/user_api.dart';
import 'package:eventorize_app/common/network/dio_client.dart';
import 'package:eventorize_app/common/errors/api_error_handler.dart';

class HealthCheckPage extends StatefulWidget {
  const HealthCheckPage({super.key});

  @override
  HealthCheckPageState createState() => HealthCheckPageState();
}

class HealthCheckPageState extends State<HealthCheckPage> {
  String _result = 'Press the button to test the API';
  bool _isLoading = false;

  Future<void> testHealthCheck() async {
    setState(() {
      _isLoading = true;
      _result = 'Calling API...';
    });

    try {
      final dioClient = DioClient();
      final userApi = UserApi(dioClient);
      final userRepository = UserRepository(userApi);
      final response = await userRepository.checkHealth();
      setState(() {
        _result = response['ping'] as String? ?? 'No ping value';
      });
    } catch (e) {
      if (e is ApiException) {
        setState(() {
          _result = 'Error: ${e.message} (Code: ${e.code}${e.statusCode != null ? ', Status: ${e.statusCode}' : ''})';
        });
      } else {
        setState(() {
          _result = 'Unexpected error: $e';
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Check'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _result,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : testHealthCheck,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Test Health Check API'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}