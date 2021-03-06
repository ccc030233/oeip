// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "Engine.h"
#include "OeipDisplayActor.generated.h"


UCLASS()
class OEIPPLUGINS_API AOeipDisplayActor : public AActor
{
	GENERATED_BODY()

public:
	// Sets default values for this actor's properties
	AOeipDisplayActor();
public:
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Oeip)
		class AStaticMeshActor* actor;
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Oeip)
		class UMaterialInterface* material;
public:
	UFUNCTION(BlueprintCallable)
		void SetTexture(UTexture2D *texture);
private:
	class UMaterialInstanceDynamic* materialDynamic = nullptr;
protected:
	// Called when the game starts or when spawned
	virtual void BeginPlay() override;
public:
	// Called every frame
	virtual void Tick(float DeltaTime) override;
};
