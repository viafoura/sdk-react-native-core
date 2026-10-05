import {
  CustomUITheme,
  CustomUIViewType,
  ViafouraCustomUI,
} from '@viafoura/sdk-react-native';

export function applyCustomUI() {
  ViafouraCustomUI.setCustomUIStyle(CustomUIViewType.previewPoweredByView, {
    visibility: 'hidden',
  });
  ViafouraCustomUI.setCustomUIStyle(CustomUIViewType.previewPoweredBy, {
    visibility: 'hidden',
  });
  ViafouraCustomUI.setCustomUIStyle(CustomUIViewType.liveQuestionPoweredByView, {
    visibility: 'hidden',
  });

  ViafouraCustomUI.setCustomUIStyle(CustomUIViewType.conversationStarterActionButton, {
    cornerRadius: 20,
    borderWidth: 1,
    borderColor: '#1D5EFF',
  });

  ViafouraCustomUI.setCustomUIStyle(CustomUIViewType.liveQuestionTitleLabel, {
    fontFamily: 'Lora-Bold',
    fontSize: 22,
  });
  ViafouraCustomUI.setCustomUIStyle(CustomUIViewType.liveQuestionCellHostPillView, {
    backgroundColor: '#1D5EFF',
    cornerRadius: 10,
  });

  ViafouraCustomUI.setCustomUIStyle(
    CustomUIViewType.commentCellNameLabel,
    { textColor: '#1D5EFF' },
    CustomUITheme.Light,
  );
  ViafouraCustomUI.setCustomUIStyle(
    CustomUIViewType.commentCellUserText,
    { textColor: '#1D5EFF' },
    CustomUITheme.Light,
  );
  ViafouraCustomUI.setCustomUIStyle(
    CustomUIViewType.commentCellNameLabel,
    { textColor: '#8AB4FF' },
    CustomUITheme.Dark,
  );
  ViafouraCustomUI.setCustomUIStyle(
    CustomUIViewType.commentCellUserText,
    { textColor: '#8AB4FF' },
    CustomUITheme.Dark,
  );
}
