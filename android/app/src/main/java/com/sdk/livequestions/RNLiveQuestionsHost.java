package com.sdk.livequestions;

import android.content.Context;
import android.view.Choreographer;
import android.widget.FrameLayout;
import androidx.annotation.Nullable;

public class RNLiveQuestionsHost extends FrameLayout {

    int reactNativeViewId;
    int propHeight;
    String containerId;
    String authorId;
    String title;
    String sectionUUID;
    boolean darkMode;
    String articleUrl, articleTitle, articleDesc, articleThumbnailUrl;

    @Nullable Choreographer.FrameCallback layoutCallback;

    public RNLiveQuestionsHost(Context context) {
        super(context);
    }

    void stopLayoutCallback() {
        if (layoutCallback != null) {
            Choreographer.getInstance().removeFrameCallback(layoutCallback);
            layoutCallback = null;
        }
    }
}
