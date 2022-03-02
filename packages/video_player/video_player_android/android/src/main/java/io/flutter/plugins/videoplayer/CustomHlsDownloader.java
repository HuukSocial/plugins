package io.flutter.plugins.videoplayer;

import android.net.Uri;

import androidx.annotation.Nullable;

import com.google.android.exoplayer2.MediaItem;
import com.google.android.exoplayer2.offline.SegmentDownloader;
import com.google.android.exoplayer2.source.hls.playlist.HlsMasterPlaylist;
import com.google.android.exoplayer2.source.hls.playlist.HlsMediaPlaylist;
import com.google.android.exoplayer2.source.hls.playlist.HlsPlaylist;
import com.google.android.exoplayer2.source.hls.playlist.HlsPlaylistParser;
import com.google.android.exoplayer2.upstream.DataSource;
import com.google.android.exoplayer2.upstream.DataSpec;
import com.google.android.exoplayer2.upstream.ParsingLoadable.Parser;
import com.google.android.exoplayer2.upstream.cache.CacheDataSource;
import com.google.android.exoplayer2.util.UriUtil;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.concurrent.Executor;

public final class CustomHlsDownloader extends SegmentDownloader<HlsPlaylist> {
    public CustomHlsDownloader(MediaItem mediaItem, CacheDataSource.Factory cacheDataSourceFactory) {
        this(mediaItem, cacheDataSourceFactory, Runnable::run);
    }

    public CustomHlsDownloader(
            MediaItem mediaItem, CacheDataSource.Factory cacheDataSourceFactory, Executor executor) {
        this(mediaItem, new HlsPlaylistParser(), cacheDataSourceFactory, executor);
    }

    public CustomHlsDownloader(
            MediaItem mediaItem,
            Parser<HlsPlaylist> manifestParser,
            CacheDataSource.Factory cacheDataSourceFactory,
            Executor executor) {
        super(mediaItem, manifestParser, cacheDataSourceFactory, executor);
    }

    @Override
    protected List<Segment> getSegments(DataSource dataSource, HlsPlaylist playlist, boolean removing)
            throws IOException, InterruptedException {
        ArrayList<DataSpec> mediaPlaylistDataSpecs = new ArrayList<>();
        if (playlist instanceof HlsMasterPlaylist) {
            HlsMasterPlaylist masterPlaylist = (HlsMasterPlaylist) playlist;
            addMediaPlaylistDataSpecs(masterPlaylist.mediaPlaylistUrls, mediaPlaylistDataSpecs);
        } else {
            mediaPlaylistDataSpecs.add(
                    SegmentDownloader.getCompressibleDataSpec(Uri.parse(playlist.baseUri)));
        }

        ArrayList<Segment> segments = new ArrayList<>();
        HashSet<Uri> seenEncryptionKeyUris = new HashSet<>();
        for (DataSpec mediaPlaylistDataSpec : mediaPlaylistDataSpecs) {
            segments.add(new Segment(/* startTimeUs= */ 0, mediaPlaylistDataSpec));
            HlsMediaPlaylist mediaPlaylist;
            try {
                mediaPlaylist = (HlsMediaPlaylist) getManifest(dataSource, mediaPlaylistDataSpec, removing);
            } catch (IOException e) {
                if (!removing) {
                    throw e;
                }
                // Generating an incomplete segment list is allowed. Advance to the next media playlist.
                continue;
            }
            @Nullable HlsMediaPlaylist.Segment lastInitSegment = null;
            List<HlsMediaPlaylist.Segment> hlsSegments = mediaPlaylist.segments;
            for (int i = 0; i < hlsSegments.size(); i++) {
                HlsMediaPlaylist.Segment segment = hlsSegments.get(i);
                HlsMediaPlaylist.Segment initSegment = segment.initializationSegment;
                if (initSegment != null && initSegment != lastInitSegment) {
                    lastInitSegment = initSegment;
                    addSegment(mediaPlaylist, initSegment, seenEncryptionKeyUris, segments);
                }
                addSegment(mediaPlaylist, segment, seenEncryptionKeyUris, segments);
            }
        }

        ArrayList<Segment> filteredSegments = new ArrayList<>();
        boolean isAddedFirstTsSegment = false;
        for (Segment segment : segments) {
            if (segment.startTimeUs == 0) {
                if (segment.dataSpec.uri.toString().endsWith("m3u8")) {
                    filteredSegments.add(segment);
                } else if (!isAddedFirstTsSegment) {
                    filteredSegments.add(segment);
                    isAddedFirstTsSegment = true;
                }
            }
        }
        return filteredSegments;
    }

    private void addMediaPlaylistDataSpecs(List<Uri> mediaPlaylistUrls, List<DataSpec> out) {
        for (int i = 0; i < mediaPlaylistUrls.size(); i++) {
            out.add(SegmentDownloader.getCompressibleDataSpec(mediaPlaylistUrls.get(i)));
        }
    }

    private void addSegment(
            HlsMediaPlaylist mediaPlaylist,
            HlsMediaPlaylist.Segment segment,
            HashSet<Uri> seenEncryptionKeyUris,
            ArrayList<Segment> out) {
        String baseUri = mediaPlaylist.baseUri;
        long startTimeUs = mediaPlaylist.startTimeUs + segment.relativeStartTimeUs;
        if (segment.fullSegmentEncryptionKeyUri != null) {
            Uri keyUri = UriUtil.resolveToUri(baseUri, segment.fullSegmentEncryptionKeyUri);
            if (seenEncryptionKeyUris.add(keyUri)) {
                out.add(new Segment(startTimeUs, SegmentDownloader.getCompressibleDataSpec(keyUri)));
            }
        }
        Uri segmentUri = UriUtil.resolveToUri(baseUri, segment.url);
        DataSpec dataSpec = new DataSpec(segmentUri, segment.byteRangeOffset, segment.byteRangeLength);
        out.add(new Segment(startTimeUs, dataSpec));
    }
}
