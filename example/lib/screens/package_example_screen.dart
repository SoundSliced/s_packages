import 'package:flutter/material.dart';
import 'package:s_packages_example/models/package_info.dart';
import 'package:s_packages_example/utils/package_examples_registry.dart';

class PackageExampleScreen extends StatelessWidget {
  final PackageInfo package;

  const PackageExampleScreen({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    final bool hasExample = PackageExamplesRegistry.hasExample(package.name);

    return Scaffold(
      appBar: AppBar(title: Text(package.displayName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasExample
                    ? Icons.check_circle
                    : Icons.integration_instructions,
                size: 80,
                color: hasExample
                    ? Colors.green
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                package.displayName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                package.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      hasExample
                          ? Icons.play_circle_outline
                          : Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasExample ? 'Example Available' : 'Example Coming Soon',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasExample
                          ? 'Tap the button below to run the interactive example'
                          : 'Check the ${package.name}/example folder for sample code',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (hasExample)
                FilledButton.icon(
                  onPressed: () {
                    final exampleWidget =
                        PackageExamplesRegistry.getExample(package.name);
                    if (exampleWidget != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => exampleWidget,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Run Example'),
                )
              else
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Example not yet available for ${package.name}',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.code),
                  label: const Text('View Package Code'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
