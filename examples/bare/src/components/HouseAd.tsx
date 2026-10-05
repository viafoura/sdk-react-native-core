import React from 'react';
import { StyleSheet, Text, View } from 'react-native';

export const HOUSE_AD_HEIGHT = 120;

const styles = StyleSheet.create({
  container: {
    height: HOUSE_AD_HEIGHT,
    marginHorizontal: 16,
    padding: 16,
    borderRadius: 12,
    backgroundColor: '#FFF4E5',
    borderColor: '#FFB84D',
    borderWidth: 1,
    justifyContent: 'center',
  },
  label: {
    fontSize: 11,
    letterSpacing: 1,
    textTransform: 'uppercase',
    color: '#9A6400',
  },
  title: {
    fontSize: 16,
    fontWeight: '600',
    marginTop: 4,
    color: '#1B2430',
  },
  body: {
    fontSize: 13,
    marginTop: 4,
    color: '#5A6472',
  },
});

const HouseAd = ({ position }: { position: number }) => (
  <View style={styles.container}>
    <Text style={styles.label}>Advertisement</Text>
    <Text style={styles.title}>House ad in slot {position}</Text>
    <Text style={styles.body}>
      Any React element works here: a Google Mobile Ads banner, a promo card, or
      this placeholder.
    </Text>
  </View>
);

export default HouseAd;
