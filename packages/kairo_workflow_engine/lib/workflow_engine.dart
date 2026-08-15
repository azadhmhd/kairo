/// Triggers, conditions, actions and the engine that runs them.
///
/// Every user-visible behaviour in Kairo — a reminder, a nudge, a streak — is
/// expressed as a workflow, so behaviour is described in one language rather
/// than reimplemented per feature.
///
/// A workflow is a trigger, some conditions and some actions, all written as
/// ordinary Dart. There is no rule format, no parser and no editor.
library;

export 'src/kairo_workflow_engine.dart';
export 'src/workflow.dart';
