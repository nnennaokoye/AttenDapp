"use client";

import React from 'react';
import OrganizationList from '@/components/organizations/OrganizationList';

export default function OrganizationsPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-8">Organizations</h1>
      <OrganizationList />
    </div>
  );
}
