"use client";

import React from 'react';
import CreateOrganization from '@/components/organizations/CreateOrganization';

export default function CreateOrganizationPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-8">Create Organization</h1>
      <CreateOrganization />
    </div>
  );
}
