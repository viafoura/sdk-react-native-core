import type { ViafouraColors } from '@viafoura/sdk-react-native';

export const SITE_UUID = '00000000-0000-4000-8000-c8cddfd7b365';
export const SITE_DOMAIN = 'viafoura-mobile-demo.vercel.app';

export const viafouraColors: ViafouraColors = {
  colorPrimary: '#1D5EFF',
  colorPrimaryLight: '#E8F0FF',
};

const sharedArticle = {
  authorId: '7548800024996',
  articleTitle: 'Moving Staff to Cover the Coronavirus',
  articleDesc:
    'Here Are What Media Companies Are Doing to Deal With COVID-19 Information Overload',
  articleUrl:
    'https://viafoura-mobile-demo.vercel.app/posts/here-are-what-media-companies-are-doing-with-covid-19-overload',
  articleThumbnailUrl:
    'https://www.datocms-assets.com/55856/1636753460-information-overload.jpg?crop=focalpoint&fit=crop&fm=webp&fp-x=0.86&fp-y=0.47&h=428&w=856',
};

export const articles = [
  { ...sharedArticle, containerId: '101113541' },
  { ...sharedArticle, containerId: '1254' },
];

export const liveQuestions = {
  ...articles[1],
  title: 'Live Q&A',
};
